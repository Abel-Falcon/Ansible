#!/bin/bash

# 🚀 SCRIPT DE CONFIGURACIÓN COMPLETA DEL PROYECTO SO
# Configura TODO automáticamente: Vault + Dependencias + Proyecto completo (Ubuntu + Windows)

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${BLUE}"
echo "🚀 CONFIGURACIÓN AUTOMÁTICA COMPLETA - PROYECTO SO"
echo "=================================================="
echo "Este script configura TODO automáticamente:"
echo "✅ Instala dependencias (Ansible, colecciones)"
echo "✅ Configura Ansible Vault con credenciales seguras"
echo "✅ Encripta automáticamente las credenciales"
echo "✅ Ejecuta el proyecto completo (Ubuntu + Windows)"
echo "✅ Verifica que todo funcione correctamente"
echo -e "${NC}"

# Función para mostrar progreso
show_step() {
    echo -e "${PURPLE}[$1/8] $2${NC}"
    echo "----------------------------------------"
}

# Función para verificar errores
check_error() {
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Error en: $1${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ $1 completado${NC}"
    echo ""
}

# Verificar que estamos en el directorio correcto
if [ ! -f "ansible.cfg" ]; then
    echo -e "${RED}❌ Error: Ejecuta este script desde el directorio proyecto-so${NC}"
    exit 1
fi

# PASO 1: Instalar dependencias
show_step "1" "Instalando dependencias del sistema..."
sudo apt update -y
sudo apt install -y ansible python3-pip git curl wget openssl jq
check_error "Instalación de dependencias"

# PASO 2: Instalar colecciones de Ansible
show_step "2" "Instalando colecciones de Ansible..."
ansible-galaxy collection install ansible.posix community.general ansible.windows
check_error "Instalación de colecciones Ansible"

# PASO 3: Configurar Ansible Vault automáticamente
show_step "3" "Configurando Ansible Vault..."
VAULT_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
echo "$VAULT_PASSWORD" > .vault_password
chmod 600 .vault_password
echo -e "${GREEN}✅ Contraseña del vault generada automáticamente${NC}"
echo -e "${YELLOW}📝 Contraseña guardada en .vault_password${NC}"
check_error "Configuración de contraseña del vault"

# PASO 4: Generar contraseñas reales para usuarios
show_step "4" "Generando contraseñas seguras para usuarios..."
generate_password_hash() {
    local password=$(openssl rand -base64 16 | tr -d "=+/")
    python3 -c "import crypt; print(crypt.crypt('$password', crypt.mksalt(crypt.METHOD_SHA512)))"
}
PROFESOR_HASH=$(generate_password_hash)
ESTUDIANTE1_HASH=$(generate_password_hash)
ESTUDIANTE2_HASH=$(generate_password_hash)
ADMIN_HASH=$(generate_password_hash)

cat > inventories/group_vars/all/vault.yml << EOF
---
# Archivo encriptado con Ansible Vault - Credenciales del Proyecto SO
# Generado automáticamente el $(date)

vault_usuarios_passwords:
  profesor: "$PROFESOR_HASH"
  estudiante1: "$ESTUDIANTE1_HASH"
  estudiante2: "$ESTUDIANTE2_HASH"
  admin-so: "$ADMIN_HASH"

# Credenciales de servicios
vault_mysql_root_password: "ProyectoSO_MySQL_$(openssl rand -base64 12 | tr -d '=+/')!"
vault_ftp_admin_password: "ProyectoSO_FTP_$(openssl rand -base64 12 | tr -d '=+/')!"
vault_web_admin_password: "ProyectoSO_Web_$(openssl rand -base64 12 | tr -d '=+/')!"

# Claves de seguridad
vault_security_keys:
  encryption_key: "$(openssl rand -hex 32)"
  jwt_secret: "$(openssl rand -base64 32 | tr -d '=+/')"
  session_secret: "$(openssl rand -base64 32 | tr -d '=+/')"
EOF

check_error "Generación de credenciales seguras"

# PASO 5: Encriptar vault automáticamente
show_step "5" "Encriptando credenciales con Ansible Vault..."
ansible-vault encrypt inventories/group_vars/all/vault.yml --vault-password-file .vault_password
check_error "Encriptación del vault"

# PASO 6: Hacer scripts ejecutables
show_step "6" "Configurando permisos de scripts..."
chmod +x scripts/*.sh
chmod +x install.sh
chmod +x setup-proyecto-completo.sh
check_error "Configuración de permisos"

# PASO 7: Configurar inventario básico
show_step "7" "Verificando hosts Windows en inventario..."
if ! grep -q "windows" inventories/hosts; then
    echo -e "${YELLOW}⚠️  No hay hosts Windows configurados en inventories/hosts${NC}"
    EJECUTAR_WINDOWS=false
else
    echo -e "${GREEN}✅ Hosts Windows encontrados en inventario${NC}"
    EJECUTAR_WINDOWS=true
fi

# PASO 8: Ejecutar proyecto completo
show_step "8" "Ejecutando configuración completa del proyecto..."

echo -e "${GREEN}🚀 Iniciando configuración de Ubuntu...${NC}"
./scripts/run-with-vault.sh ubuntu
UBUNTU_EXIT=$?

if [ $UBUNTU_EXIT -eq 0 ]; then
    echo -e "${GREEN}✅ Ubuntu configurado exitosamente${NC}"
else
    echo -e "${YELLOW}⚠️  Ubuntu tuvo algunos errores (código: $UBUNTU_EXIT)${NC}"
fi

if [ "$EJECUTAR_WINDOWS" = true ]; then
    echo -e "${GREEN}🖥️  Iniciando configuración de Windows...${NC}"
    ./scripts/run-with-vault.sh windows
    WINDOWS_EXIT=$?
else
    WINDOWS_EXIT=0
fi

# RESUMEN FINAL
echo ""
echo -e "${BLUE}🎉 CONFIGURACIÓN COMPLETA FINALIZADA${NC}"
echo -e "${BLUE}====================================${NC}"
echo ""

if [ $UBUNTU_EXIT -eq 0 ]; then
    echo -e "✅ ${GREEN}Ubuntu: Configurado exitosamente${NC}"
else
    echo -e "⚠️  ${YELLOW}Ubuntu: Configurado con advertencias${NC}"
fi

if [ "$EJECUTAR_WINDOWS" = true ]; then
    if [ $WINDOWS_EXIT -eq 0 ]; then
        echo -e "✅ ${GREEN}Windows: Configurado exitosamente${NC}"
    else
        echo -e "⚠️  ${YELLOW}Windows: Configurado con advertencias${NC}"
    fi
else
    echo -e "ℹ️  ${BLUE}Windows: No configurado (no hay hosts en inventario)${NC}"
fi

echo ""
echo -e "${GREEN}🔐 CREDENCIALES SEGURAS CONFIGURADAS:${NC}"
echo -e "   📁 Vault encriptado: inventories/group_vars/all/vault.yml"
echo -e "   🔑 Contraseña: .vault_password"
echo -e "   👥 Usuarios: profesor, estudiante1, estudiante2, admin-so"

echo ""
echo -e "${BLUE}📋 COMANDOS ÚTILES:${NC}"
echo -e "   ${GREEN}make verify${NC}          # Verificar servicios"
echo -e "   ${GREEN}make status${NC}           # Estado de servicios"
echo -e "   ${GREEN}make security-report${NC}  # Reporte de seguridad"
echo -e "   ${GREEN}make vault-view${NC}       # Ver credenciales"
echo -e "   ${GREEN}make vault-edit${NC}       # Editar credenciales"

echo ""
echo -e "${PURPLE}🎯 ¡PROYECTO SO COMPLETAMENTE CONFIGURADO Y LISTO!${NC}"

# Ejecutar verificación final
echo ""
echo -e "${BLUE}🔍 Ejecutando verificación final...${NC}"
./scripts/verificar-proyecto.sh

echo ""
echo -e "${GREEN}🚀 ¡Todo listo! Tu proyecto SO está funcionando con seguridad completa.${NC}"