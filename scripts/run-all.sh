#!/bin/bash

# Script maestro para ejecutar configuración completa del Proyecto SO
# Configura tanto Ubuntu Server (servicios) como Windows (cliente)

echo "🌟 PROYECTO DE SISTEMAS OPERATIVOS - CONFIGURACIÓN COMPLETA"
echo "============================================================"
echo "Este script configurará:"
echo "🖥️  Ubuntu Server: Servicios de red (HTTP, FTP, DNS, DHCPv6, IPv6, usuarios)"
echo "💻 Windows: Sistema cliente (usuarios, software, optimización, apariencia)"
echo "============================================================"

# Cambiar al directorio raíz del proyecto
cd "$(dirname "$0")/.." || exit 1

# Función para mostrar progreso
show_progress() {
    echo ""
    echo "⏳ $1..."
    echo "------------------------------------------------------------"
}

# Verificar prerrequisitos
show_progress "Verificando prerrequisitos"

if ! command -v ansible-playbook &> /dev/null; then
    echo "❌ Ansible no está instalado. Instalando..."
    if [ -f /etc/debian_version ]; then
        sudo apt update && sudo apt install -y ansible
    else
        echo "⚠️  Sistema no Debian/Ubuntu detectado. Instala Ansible manualmente."
        exit 1
    fi
fi

# Ejecutar configuración de Ubuntu Server
show_progress "Configurando Ubuntu Server (localhost o red interna)"
./scripts/run-ubuntu.sh
UBUNTU_EXIT=$?

if [ $UBUNTU_EXIT -ne 0 ]; then
    echo "❌ Error en la configuración de Ubuntu Server"
    echo "🛑 Deteniendo ejecución"
    exit $UBUNTU_EXIT
fi

# Pausa entre configuraciones
echo ""
echo "⏸️  Pausa de 5 segundos antes de configurar Windows..."
sleep 5

# Ejecutar configuración de Windows
show_progress "Configurando Windows"
./scripts/run-windows.sh
WINDOWS_EXIT=$?

# Resumen final
echo ""
echo "============================================================"
echo "📊 RESUMEN DE CONFIGURACIÓN"
echo "============================================================"

if [ $UBUNTU_EXIT -eq 0 ]; then
    echo "✅ Ubuntu Server: Configuración exitosa"
else
    echo "❌ Ubuntu Server: Error (código $UBUNTU_EXIT)"
fi

if [ $WINDOWS_EXIT -eq 0 ]; then
    echo "✅ Windows: Configuración exitosa"
else
    echo "❌ Windows: Error (código $WINDOWS_EXIT)"
fi

echo "============================================================"

# Determinar código de salida final
if [ $UBUNTU_EXIT -eq 0 ] && [ $WINDOWS_EXIT -eq 0 ]; then
    echo "🎉 ¡PROYECTO COMPLETADO EXITOSAMENTE!"
    echo "🌐 Todos los servicios y sistemas están configurados correctamente"
    exit 0
else
    echo "⚠️  Proyecto completado con errores"
    echo "💡 Revisa los logs de Ansible para más detalles"
    exit 1
fi
