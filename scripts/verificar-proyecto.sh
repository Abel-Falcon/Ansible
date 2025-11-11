#!/bin/bash

# Script de verificación del Proyecto SO
# Verifica que todos los servicios estén funcionando correctamente

echo "🔍 VERIFICACIÓN DEL PROYECTO SO"
echo "==============================="

cd "$(dirname "$0")/.." || exit 1

# Función para verificar servicios
verificar_servicio() {
    local servicio=$1
    local puerto=$2
    local host=${3:-localhost}
    
    echo -n "🔹 $servicio ($puerto): "
    
    if systemctl is-active --quiet "$servicio" 2>/dev/null; then
        echo "✅ Activo"
        if [ -n "$puerto" ]; then
            if netstat -tuln 2>/dev/null | grep -q ":$puerto "; then
                echo "   Puerto $puerto: ✅ Abierto"
            else
                echo "   Puerto $puerto: ❌ Cerrado"
            fi
        fi
    else
        echo "❌ Inactivo"
    fi
}

# Función para verificar conectividad
verificar_conectividad() {
    local host=$1
    local descripcion=$2
    
    echo -n "🌐 $descripcion ($host): "
    
    if ping -c 1 -W 2 "$host" &>/dev/null; then
        echo "✅ Conectado"
    else
        echo "❌ Sin conexión"
    fi
}

echo ""
echo "📊 VERIFICACIÓN DE UBUNTU (localhost)"
echo "====================================="

# Verificar servicios típicos de Ubuntu
verificar_servicio "apache2" "80"
verificar_servicio "vsftpd" "21"
verificar_servicio "ufw" ""
verificar_servicio "fail2ban" ""
verificar_servicio "ssh" ""

echo ""
echo "🌐 VERIFICACIÓN DE CONECTIVIDAD WEB"
echo "==================================="
# HTTP
echo -n "🔹 HTTP (puerto 80): "
if curl -s -o /dev/null -w "%{http_code}" http://localhost | grep -q "200"; then
    echo "✅ Respondiendo"
else
    echo "❌ No responde"
fi

# FTP
echo -n "🔹 FTP (puerto 21): "
if nc -z localhost 21 2>/dev/null; then
    echo "✅ Abierto"
else
    echo "❌ Cerrado"
fi

# DNS (localhost)
echo -n "🔹 DNS (puerto 53): "
if nslookup proyecto-so.local localhost &>/dev/null; then
    echo "✅ Resolviendo"
else
    echo "❌ No resuelve"
fi

echo ""
echo "👥 VERIFICACIÓN DE USUARIOS"
echo "==========================="
for usuario in profesor estudiante1 estudiante2 admin-so; do
    echo -n "🔹 Usuario $usuario: "
    if id "$usuario" &>/dev/null; then
        echo "✅ Existe"
        if [ -d "/home/$usuario" ]; then
            echo "   Home: ✅ Existe"
        else
            echo "   Home: ❌ No existe"
        fi
    else
        echo "❌ No existe"
    fi
done

echo ""
echo "🎮 VERIFICACIÓN DE WINDOWS (remoto)"
echo "=================================="
if ansible-inventory -i inventories/hosts --list 2>/dev/null | grep -q "windows"; then
    echo "🔹 Hosts Windows configurados: ✅"
    
    ansible windows -i inventories/hosts -m win_ping --one-line 2>/dev/null | while read line; do
        if echo "$line" | grep -q "SUCCESS"; then
            host=$(echo "$line" | cut -d'|' -f1 | tr -d ' ')
            echo "🔹 $host: ✅ Conectado"
        elif echo "$line" | grep -q "UNREACHABLE"; then
            host=$(echo "$line" | cut -d'|' -f1 | tr -d ' ')
            echo "🔹 $host: ❌ Sin conexión"
        fi
    done
else
    echo "🔹 Hosts Windows: ⚠️  No configurados"
    echo "   Edita inventories/hosts para agregar sistemas Windows"
fi

echo ""
echo "📋 RESUMEN DE LOGS RECIENTES"
echo "============================"
echo "🔹 Últimas 5 líneas del log del sistema:"
journalctl --since "1 hour ago" --no-pager | tail -5

echo ""
echo "🛡️  VERIFICACIÓN DE SEGURIDAD"
echo "============================="

echo -n "🔹 Estado del firewall: "
if ufw status &>/dev/null; then
    echo "✅ Activo"
    echo "   Reglas: $(ufw status | grep -v Status)"
else
    echo "❌ Inactivo"
fi

echo -n "🔹 Fail2ban: "
if systemctl is-active --quiet fail2ban; then
    echo "✅ Activo"
else
    echo "❌ Inactivo"
fi

echo ""
echo "🎯 VERIFICACIÓN COMPLETADA"
echo "=========================="
echo "💡 Para reconfigurar sistemas si es necesario:"
echo "   ./scripts/run-ubuntu.sh   # Para reconfigurar Ubuntu"
echo "   ./scripts/run-windows.sh  # Para reconfigurar Windows"
