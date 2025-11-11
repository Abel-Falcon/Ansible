#!/bin/bash
set -e

# Cambiar al directorio del proyecto
cd "$(dirname "$0")/.." || exit

echo "🔐 Recreando vault con contraseñas correctas..."

cat > /tmp/vault_fix.yml << 'EOF'
---
vault_ubuntu_passwords:
  profesor: "Profesor2025!"
  estudiante1: "Estudiante1SO!"
  estudiante2: "Estudiante2SO!"
  admin-so: "AdminSO2025!"

vault_windows_passwords:
  profesor: "ProfesorWin2025!"
  estudiante1: "Estudiante1Win!"
  estudiante2: "Estudiante2Win!"
  admin-so: "AdminWin2025!"

vault_local_sudo: "Qwe123$"
EOF

echo "✅ Archivo vault en texto plano creado"
cat /tmp/vault_fix.yml

# Cifrar con vault-id
echo "🔒 Cifrando con vault-id proyecto-so..."
ansible-vault encrypt --encrypt-vault-id proyecto-so /tmp/vault_fix.yml

# Mover al lugar correcto
echo "📦 Instalando vault cifrado..."
mv -f /tmp/vault_fix.yml inventories/group_vars/all/vault.yml

# Verificar
echo "✅ Verificando vault..."
ansible-vault view --vault-id proyecto-so@.vault_password inventories/group_vars/all/vault.yml

echo ""
echo "🎯 Vault recreado. Ahora puedes ejecutar los playbooks:"
echo "   ./scripts/run-with-vault.sh ubuntu"
echo "   ./scripts/run-with-vault.sh windows"
