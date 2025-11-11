#!/bin/bash

# Script para ejecutar configuración de Ubuntu Server
# Ejecuta desde localhost hacia localhost o red interna

echo "🚀 Iniciando configuración de Ubuntu Server..."
echo "================================================"

# Verificar que estamos en Ubuntu
if ! grep -q "Ubuntu" /etc/os-release 2>/dev/null; then
    echo "⚠️  Advertencia: Este script está diseñado para ejecutarse en Ubuntu Server"
fi

# Cambiar al directorio del proyecto
cd "$(dirname "$0")/.." || exit 1

# Verificar que Ansible está instalado
if ! command -v ansible-playbook &> /dev/null; then
    echo "❌ Ansible no está instalado. Instalando..."
    sudo apt update
    sudo apt install -y ansible
    ansible-galaxy collection install community.general
    ansible-galaxy collection install ansible.posix
fi

# Ejecutar playbook específico para Ubuntu Server
echo "📋 Ejecutando playbook de Ubuntu Server..."
ansible-playbook playbooks/ubuntu.yml -i inventories/hosts -l ubuntu -K -v

EXIT_CODE=$?

echo "================================================"
if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ Configuración de Ubuntu Server completada exitosamente"
    echo "🌐 Servicios configurados:"
    echo "   - HTTP (Apache2) en puerto 80"
    echo "   - FTP (vsftpd)"
    echo "   - DNS (Bind9)"
    echo "   - DHCPv6"
    echo "   - IPv6 / Firewall / Usuarios"
else
    echo "❌ Error en la configuración. Código de salida: $EXIT_CODE"
    echo "💡 Revisa los logs arriba para más detalles"
fi

exit $EXIT_CODE