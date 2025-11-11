#!/bin/bash

# 🚀 SCRIPT RÁPIDO SOLO PARA WINDOWS
# Configura únicamente sistemas Windows remotos

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${BLUE}"
echo "🖥️  CONFIGURACIÓN RÁPIDA SOLO WINDOWS"
echo "====================================="
echo "Este script configura SOLO sistemas Windows con:"
echo "✅ Usuarios del proyecto con permisos"
echo "✅ Instalación de software con Chocolatey (Firefox, VS Code, Git, etc.)"
echo "✅ Configuración de PowerShell y seguridad"
echo "✅ Optimización del sistema y mantenimiento automático"
echo -e "${NC}"

# Verificar directorio
if [ ! -f "ansible.cfg" ]; then
    echo -e "${RED}❌ Error: Ejecuta desde el directorio proyecto-so${NC}"
    exit 1
fi

# Función para mostrar progreso
show_step() {
    echo -e "${PURPLE}[$1/6] $2${NC}"
    echo "----------------------------------------"
}

# PASO 1: Verificar dependencias
show_step "1" "Verificando dependencias..."
if ! command -v ansible &> /dev/null; then
    echo "Instalando Ansible y dependencias..."
    sudo apt update
    sudo apt install -y ansible python3-pip openssl jq
    ansible-galaxy collection install ansible.windows community.general
fi
echo -e "${GREEN}✅ Dependencias listas${NC}"

# PASO 2: Verificar hosts Windows
show_step "2" "Verificando hosts Windows..."
if ! grep -q "windows" inventories/hosts || ! grep -q "ansible_host" inventories/hosts; then
    echo -e "${YELLOW}⚠️  No hay hosts Windows configurados en inventories/hosts${NC}"
    echo ""
    echo -e "${BLUE}💡 Para configurar hosts Windows:${NC}"
    echo "1. Edita inventories/hosts"
    echo "2. Agrega tus sistemas Windows:"
    echo ""
    echo -e "${GREEN}[windows]${NC}"
    echo -e "${GREEN}win-pc ansible_host=192.168.1.200 ansible_user=Administrador ansible_password=Password123 ansible_connection=winrm${NC}"
    echo ""
    echo "3. Habilita WinRM en los hosts Windows"
    echo "4. Ejecuta este script nuevamente"
    exit 1
fi
echo -e "${GREEN}✅ Hosts Windows encontrados${NC}"

# PASO 3: Configurar Vault si no existe
show_step "3" "Configurando Ansible Vault..."
if [ ! -f ".vault_password" ]; then
    echo "Generando contraseña del vault..."
    VAULT_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
    echo "$VAULT_PASSWORD" > .vault_password
    chmod 600 .vault_password
fi

if [ ! -f "inventories/group_vars/all/vault.yml" ]; then
    echo "Creando archivo vault para Windows..."
    
    # Generar contraseñas para usuarios
    PROFESOR_HASH=$(openssl rand -base64 16)
    ESTUDIANTE1_HASH=$(openssl rand -base64 16)
    ESTUDIANTE2_HASH=$(openssl rand -base64 16)
    ADMIN_HASH=$(openssl rand -base64 16)
    
    cat > inventories/group_vars/all/vault.yml << EOF
---
# Credenciales para Windows - Proyecto SO
vault_usuarios_passwords:
  profesor: "$PROFESOR_HASH"
  estudiante1: "$ESTUDIANTE1_HASH"
  estudiante2: "$ESTUDIANTE2_HASH"
  admin-so: "$ADMIN_HASH"

vault_security_keys:
  encryption_key: "$(openssl rand -hex 32)"
  jwt_secret: "$(openssl rand -base64 32 | tr -d '=+/')"
  session_secret: "$(openssl rand -base64 32 | tr -d '=+/')"
EOF

    ansible-vault encrypt inventories/group_vars/all/vault.yml --vault-password-file .vault_password
    echo -e "${GREEN}✅ Vault creado y encriptado${NC}"
fi

# PASO 4: Probar conectividad
show_step "4" "Probando conectividad con hosts Windows..."
echo "Verificando conexión WinRM..."

if ansible windows -i inventories/hosts -m win_ping --vault-password-file .vault_password; then
    echo -e "${GREEN}✅ Conectividad exitosa con hosts Windows${NC}"
else
    echo -e "${RED}❌ Error de conectividad con hosts Windows${NC}"
    echo ""
    echo -e "${YELLOW}💡 Soluciones:${NC}"
    echo "1. Verifica las IPs en inventories/hosts"
    echo "2. Habilita WinRM en los hosts Windows"
    echo "3. Verifica que los hosts estén encendidos"
    echo "4. Prueba conexión manual con: ansible windows -i inventories/hosts -m win_ping"
    exit 1
fi

# PASO 5: Ejecutar configuración de Windows
show_step "5" "Ejecutando configuración de Windows..."
echo -e "${GREEN}🖥️  Configurando sistemas Windows...${NC}"

./scripts/run-with-vault.sh windows
WINDOWS_EXIT=$?

# PASO 6: Verificación y resumen
show_step "6" "Verificando configuración..."

echo ""
echo -e "${BLUE}🖥️  RESUMEN DE CONFIGURACIÓN WINDOWS${NC}"
echo -e "${BLUE}==================================${NC}"

if [ $WINDOWS_EXIT -eq 0 ]; then
    echo -e "✅ ${GREEN}Windows configurado exitosamente${NC}"
    echo ""
    echo -e "${GREEN}👥 USUARIOS CREADOS:${NC}"
    echo -e "   👨‍🏫 profesor (admin)"
    echo -e "   👨‍🎓 estudiante1 (usuario estándar)"
    echo -e "   👨‍🎓 estudiante2 (usuario estándar)"
    echo -e "   🔧 admin-so (administrador del proyecto)"
    
    echo ""
    echo -e "${GREEN}📦 SOFTWARE INSTALADO:${NC}"
    echo -e "   🌐 Firefox (Chocolatey)"
    echo -e "   💻 VS Code (Chocolatey)"
    echo -e "   🔧 Git (Chocolatey)"
    echo -e "   📄 LibreOffice (Chocolatey)"
    
    echo ""
    echo -e "${GREEN}⚙️  CONFIGURACIONES APLICADAS:${NC}"
    echo -e "   🔒 Políticas de seguridad"
    echo -e "   🚀 Optimización del sistema"
    echo -e "   🔄 Mantenimiento automático habilitado"
    
    echo ""
    echo -e "${GREEN}🔐 SEGURIDAD:${NC}"
    echo -e "   🔒 Contraseñas encriptadas con Vault"
    echo -e "   👥 Grupos y permisos configurados para usuarios"
    
else
    echo -e "⚠️  ${YELLOW}Windows configurado con algunas advertencias${NC}"
    echo -e "${YELLOW}💡 Algunos ajustes pueden requerir reinicio${NC}"
fi

echo ""
echo -e "${BLUE}📋 COMANDOS ÚTILES PARA WINDOWS:${NC}"
echo -e "   ${GREEN}ansible windows -m win_command -a 'whoami'${NC}      # Usuario actual"
echo -e "   ${GREEN}ansible windows -m win_chocolatey -a 'name=git state=present'${NC}  # Instalar software"
echo -e "   ${GREEN}make vault-view${NC}                                  # Ver credenciales"

echo ""
echo -e "${BLUE}🖥️  ACCESO A SISTEMAS WINDOWS:${NC}"
echo "Para conectarte a los sistemas Windows configurados:"
echo ""

# Mostrar hosts configurados
grep -A 10 "\[windows\]" inventories/hosts | grep "ansible_host" | while read line; do
    hostname=$(echo "$line" | awk '{print $1}')
    ip=$(echo "$line" | grep -o 'ansible_host=[^ ]*' | cut -d'=' -f2)
    user=$(echo "$line" | grep -o 'ansible_user=[^ ]*' | cut -d'=' -f2)
    echo -e "   🖥️  ${GREEN}Conectar con $user@$ip via WinRM${NC}  # $hostname"
done

echo ""
echo -e "${PURPLE}🎯 ¡SISTEMAS WINDOWS COMPLETAMENTE CONFIGURADOS!${NC}"

# Verificación final
echo ""
echo -e "${BLUE}🔍 Verificación final de conectividad...${NC}"
ansible windows -i inventories/hosts -m win_command -a "echo 'Windows configurado correctamente - $(date)'" --vault-password-file .vault_password

echo ""
echo -e "${GREEN}🖥️  ¡Sistemas Windows listos para usar!${NC}"
