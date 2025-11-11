#!/bin/bash

# Script para ejecutar configuración de Windows
# Ejecuta desde Ubuntu/AlmaLinux hacia sistemas Windows remotos vía Ansible/WinRM

echo "🪟 Iniciando configuración de Windows..."
echo "================================================"

# Cambiar al directorio del proyecto
cd "$(dirname "$0")/.." || exit 1

# Verificar que hay hosts Windows configurados
if ! ansible-inventory -i inventories/hosts --list | grep -q "windows"; then
    echo "⚠️  No hay hosts Windows configurados en el inventario"
    echo "💡 Edita inventories/hosts y agrega los sistemas Windows"
    exit 1
fi

# Verificar conectividad con hosts Windows
echo "🔍 Verificando conectividad con hosts Windows..."
if ! ansible windows -i inventories/hosts -m win_ping; then
    echo "❌ No se puede conectar a los hosts Windows"
    echo "💡 Verifica:"
    echo "   - Las IPs en inventories/hosts"
    echo "   - Las credenciales de WinRM (ansible_user/ansible_password)"
    echo "   - La conectividad de red"
    exit 1
fi

# Ejecutar playbook específico para Windows
echo "📋 Ejecutando playbook de Windows..."
ansible-playbook playbooks/windows.yml -i inventories/hosts -l windows -K -v

EXIT_CODE=$?

echo "================================================"
if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ Configuración de Windows completada exitosamente"
    echo "🖥️  Configuraciones aplicadas:"
    echo "   - Usuarios creados y configurados"
    echo "   - Software instalado (MSI, Chocolatey, etc.)"
    echo "   - Servicios configurados"
    echo "   - Sistema optimizado"
    echo "   - Mantenimiento automático habilitado"
else
    echo "❌ Error en la configuración. Código de salida: $EXIT_CODE"
    echo "💡 Revisa los logs arriba para más detalles"
fi

exit $EXIT_CODE
