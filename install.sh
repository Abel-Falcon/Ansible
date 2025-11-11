#!/bin/bash

# Script de instalación del Proyecto SO
# Configura el entorno y dependencias necesarias para Ubuntu + Windows

echo "🔧 INSTALADOR DEL PROYECTO SO"
echo "=============================="

# Verificar que estamos en Ubuntu
if ! grep -q "Ubuntu" /etc/os-release 2>/dev/null; then
    echo "⚠️  Este proyecto está optimizado para Ubuntu"
    echo "   Continuando de todas formas..."
fi

# Actualizar el sistema
echo "📦 Actualizando el sistema..."
sudo apt update -y && sudo apt upgrade -y

# Instalar Ansible y dependencias
echo "🤖 Instalando Ansible y dependencias..."
sudo apt install -y ansible python3-pip git openssl jq curl wget

# Instalar colecciones de Ansible necesarias
echo "📚 Instalando colecciones de Ansible..."
ansible-galaxy collection install ansible.posix
ansible-galaxy collection install community.general
ansible-galaxy collection install ansible.windows

# Verificar instalación
echo "✅ Verificando instalación..."
ansible --version
python3 --version

# Configurar SSH si es necesario
if [ ! -f ~/.ssh/id_rsa ]; then
    echo "🔑 Generando claves SSH..."
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
    echo "💡 Clave SSH generada en ~/.ssh/id_rsa.pub"
    echo "   Copia esta clave a los sistemas Windows (si usas OpenSSH) o Ubuntu remotos"
fi

# Hacer scripts ejecutables
chmod +x scripts/*.sh

echo ""
echo "🎉 ¡INSTALACIÓN COMPLETADA!"
echo "=========================="
echo "📋 Próximos pasos:"
echo "1. Edita inventories/hosts para agregar tus sistemas Ubuntu y Windows"
echo "2. Copia tu clave SSH a los sistemas remotos (si aplica):"
echo "   ssh-copy-id usuario@ip"
echo "3. Ejecuta la configuración:"
echo "   ./scripts/setup-proyecto-completo.sh  # Para todo"
echo "   ./scripts/setup-solo-ubuntu.sh        # Solo Ubuntu"
echo "   ./scripts/setup-solo-windows.sh       # Solo Windows"
echo ""
echo "📖 Lee README.md para más información"
