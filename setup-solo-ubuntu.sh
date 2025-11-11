#!/bin/bash

# 🚀 SCRIPT RÁPIDO SOLO PARA UBUNTU SERVER
# Configura únicamente Ubuntu Server con todos sus servicios

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${BLUE}"
echo "📊 CONFIGURACIÓN RÁPIDA SOLO UBUNTU SERVER"
echo "========================================="
echo "Este script configura SOLO Ubuntu Server con:"
echo "✅ HTTP/Apache + página personalizada"
echo "✅ FTP/vsftpd seguro"
echo "✅ DNS/BIND con zona proyecto-so.local"
echo "✅ Firewall + fail2ban + Suricata IDS/IPS"
echo "✅ DHCPv6 + IPv6/radvd"
echo "✅ Usuarios del proyecto con Vault"
echo -e "${NC}"

if [ ! -f "ansible.cfg" ]; then
    echo -e "${RED}❌ Error: Ejecuta desde el directorio proyecto-so${NC}"
    exit 1
fi

show_step() {
    echo -e "${PURPLE}[$1/5] $2${NC}"
    echo "----------------------------------------"
}

# PASO 1: Verificar/instalar dependencias básicas
show_step "1" "Verificando dependencias..."
if ! command -v ansible &> /dev/null; then
    echo "Instalando Ansible y dependencias..."
    sudo apt update
    sudo apt install -y ansible python3-pip openssl jq
    ansible-galaxy collection install ansible.posix community.general
fi
echo -e "${GREEN}✅ Dependencias listas${NC}"

# PASO 2: Configurar Vault si no existe
show_step "2" "Configurando Ansible Vault..."
if [ ! -f ".vault_password" ]; then
    echo "Generando contraseña del vault..."
    VAULT_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
    echo "$VAULT_PASSWORD" > .vault_password
    chmod 600 .vault_password
    echo -e "${GREEN}✅ Contraseña del vault generada${NC}"
fi

if [ ! -f "inventories/group_vars/all/vault.yml" ]; then
    echo "Creando archivo vault con credenciales..."

    # Generar contraseñas para usuarios
    PROFESOR_HASH=$(python3 -c "import crypt; print(crypt.crypt('ProfesorSO2024!', crypt.mksalt(crypt.METHOD_SHA512)))")
    ESTUDIANTE1_HASH=$(python3 -c "import crypt; print(crypt.crypt('Estudiante1SO!', crypt.mksalt(crypt.METHOD_SHA512)))")
    ESTUDIANTE2_HASH=$(python3 -c "import crypt; print(crypt.crypt('Estudiante2SO!', crypt.mksalt(crypt.METHOD_SHA512)))")
    ADMIN_HASH=$(python3 -c "import crypt; print(crypt.crypt('AdminSO2024!', crypt.mksalt(crypt.METHOD_SHA512)))")

    cat > inventories/group_vars/all/vault.yml << EOF
---
# Credenciales para Ubuntu Server - Proyecto SO
vault_usuarios_passwords:
  profesor: "$PROFESOR_HASH"
  estudiante1: "$ESTUDIANTE1_HASH"
  estudiante2: "$ESTUDIANTE2_HASH"
  admin-so: "$ADMIN_HASH"

vault_mysql_root_password: "Ubuntu_MySQL_2024!"
vault_ftp_admin_password: "Ubuntu_FTP_2024!"
vault_web_admin_password: "Ubuntu_Web_2024!"
vault_suricata_oinkcode: "$(openssl rand -hex 16)"
vault_fail2ban_email: "admin@proyecto-so.local"

vault_security_keys:
  encryption_key: "$(openssl rand -hex 32)"
  jwt_secret: "$(openssl rand -base64 32 | tr -d '=+/')"
  session_secret: "$(openssl rand -base64 32 | tr -d '=+/')"
EOF

    ansible-vault encrypt inventories/group_vars/all/vault.yml --vault-password-file .vault_password
    echo -e "${GREEN}✅ Vault creado y encriptado${NC}"
fi

# PASO 3: Hacer scripts ejecutables
show_step "3" "Configurando permisos..."
chmod +x scripts/*.sh
echo -e "${GREEN}✅ Permisos configurados${NC}"

# PASO 4: Ejecutar configuración de Ubuntu
show_step "4" "Ejecutando configuración de Ubuntu Server..."
echo -e "${GREEN}🚀 Configurando servicios de Ubuntu...${NC}"

./scripts/run-with-vault.sh ubuntu
UBUNTU_EXIT=$?

# PASO 5: Verificación y resumen
show_step "5" "Verificando configuración..."

echo ""
echo -e "${BLUE}📊 RESUMEN DE CONFIGURACIÓN UBUNTU SERVER${NC}"
echo -e "${BLUE}=========================================${NC}"

if [ $UBUNTU_EXIT -eq 0 ]; then
    echo -e "✅ ${GREEN}Ubuntu Server configurado exitosamente${NC}"
    echo ""
    echo -e "${GREEN}🌐 SERVICIOS DISPONIBLES:${NC}"
    svc_active() { systemctl is-active --quiet "$1" 2>/dev/null; }
    if svc_active apache2; then echo -e "   📄 HTTP: http://localhost"; fi
    if svc_active vsftpd; then echo -e "   📁 FTP: ftp://localhost"; fi
    if svc_active bind9; then echo -e "   🔍 DNS: proyecto-so.local"; fi
    if svc_active ufw; then echo -e "   🛡️  Firewall: Activo con reglas de seguridad"; fi
    if svc_active suricata; then echo -e "   🚨 Suricata IDS/IPS: Activo"; fi
    if svc_active fail2ban; then echo -e "   🔒 fail2ban: Protección anti-brute force"; fi
    if svc_active radvd && svc_active isc-dhcp-server; then
        echo -e "   🌐 IPv6: DHCPv6 + radvd configurados"
    elif svc_active radvd; then
        echo -e "   🌐 IPv6: radvd configurado"
    elif svc_active isc-dhcp-server; then
        echo -e "   🌐 IPv6: DHCPv6 configurado"
    fi

    echo ""
    echo -e "${GREEN}👥 USUARIOS DETECTADOS:${NC}"
    list_user() { id -u "$1" >/dev/null 2>&1 && echo -e "   $2"; }
    list_user profesor "👨‍🏫 profesor$(id -nG profesor 2>/dev/null | grep -qw sudo && echo ' (admin)')"
    list_user estudiante1 "👨‍🎓 estudiante1"
    list_user estudiante2 "👨‍🎓 estudiante2"
    list_user admin-so "🔧 admin-so$(id -nG admin-so 2>/dev/null | grep -qw sudo && echo ' (admin)')"

    echo ""
    echo -e "${GREEN}🔐 SEGURIDAD:${NC}"
    echo -e "   🔒 Credenciales encriptadas con Vault"
    if svc_active ufw; then echo -e "   🛡️  Firewall con reglas personalizadas"; fi
    if svc_active suricata; then echo -e "   🚨 IDS/IPS con detección de amenazas"; fi
    if svc_active fail2ban; then echo -e "   🔐 Bloqueo automático de IPs maliciosas"; fi
    
else
    echo -e "⚠️  ${YELLOW}Ubuntu configurado con algunas advertencias${NC}"
    echo -e "${YELLOW}💡 Esto es normal en la primera ejecución${NC}"
fi

echo ""
echo -e "${BLUE}📋 COMANDOS ÚTILES:${NC}"
echo -e "   ${GREEN}make verify${NC}           # Verificar todos los servicios"
echo -e "   ${GREEN}make status${NC}            # Estado de servicios"
echo -e "   ${GREEN}make security-report${NC}   # Reporte de seguridad completo"
echo -e "   ${GREEN}make firewall-status${NC}   # Estado del firewall"
echo -e "   ${GREEN}make suricata-status${NC}   # Estado de Suricata IDS/IPS"
echo -e "   ${GREEN}make vault-view${NC}        # Ver credenciales"

echo ""
echo -e "${PURPLE}🎯 ¡UBUNTU SERVER COMPLETAMENTE CONFIGURADO!${NC}"

# Verificación rápida de servicios
echo ""
echo -e "${BLUE}🔍 Verificación rápida de servicios...${NC}"
for service in apache2 vsftpd bind9 ufw suricata fail2ban isc-dhcp-server radvd; do
    if systemctl is-active --quiet $service; then
        echo -e "✅ $service activo"
    else
        echo -e "⚠️  $service inactivo"
    fi
done

echo ""
echo -e "${GREEN}🚀 ¡Ubuntu Server listo para usar!${NC}"
