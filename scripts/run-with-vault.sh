#!/bin/bash

VAULT_PASSWORD_FILE=".vault_password"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔐 EJECUTOR CON ANSIBLE VAULT - PROYECTO SO${NC}"
echo -e "${BLUE}===========================================${NC}"

# Verificar que existe el archivo de contraseña del vault
if [ ! -f "$VAULT_PASSWORD_FILE" ]; then
    echo -e "${RED}❌ Error: No se encontró el archivo de contraseña del vault${NC}"
    echo -e "${YELLOW}💡 Ejecuta: ./scripts/vault-setup.sh setup${NC}"
    exit 1
fi

# Verificar que el vault se puede leer
if ! ansible-vault view inventories/group_vars/all/vault.yml &>/dev/null; then
    echo -e "${RED}❌ Error: No se puede leer el archivo vault${NC}"
    echo -e "${YELLOW}💡 Verifica la contraseña del vault${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Vault configurado correctamente${NC}"

# Función para ejecutar Ubuntu con vault
run_ubuntu() {
    echo -e "${GREEN}📊 Ejecutando configuración de Ubuntu con credenciales encriptadas...${NC}"
    
    ansible-playbook playbooks/ubuntu.yml \
        -i inventories/hosts \
        -l ubuntu \
        --vault-password-file "$VAULT_PASSWORD_FILE" \
        -v
    
    return $?
}

# Función para ejecutar Windows con vault
run_windows() {
    echo -e "${GREEN}🪟 Ejecutando configuración de Windows con credenciales encriptadas...${NC}"
    
    # Verificar conectividad primero
    if ! ansible windows -i inventories/hosts -m win_ping --vault-password-file "$VAULT_PASSWORD_FILE"; then
        echo -e "${RED}❌ No se puede conectar a los hosts Windows${NC}"
        return 1
    fi
    
    ansible-playbook playbooks/windows.yml \
        -i inventories/hosts \
        -l windows \
        --vault-password-file "$VAULT_PASSWORD_FILE" \
        -v
    
    return $?
}

# Función para ejecutar todo
run_all() {
    echo -e "${GREEN}🌟 Ejecutando proyecto completo con credenciales encriptadas...${NC}"
    
    # Ejecutar Ubuntu
    run_ubuntu
    UBUNTU_EXIT=$?
    
    if [ $UBUNTU_EXIT -ne 0 ]; then
        echo -e "${RED}❌ Error en la configuración de Ubuntu${NC}"
        return $UBUNTU_EXIT
    fi
    
    # Pausa entre configuraciones
    echo -e "${YELLOW}⏸️  Pausa de 5 segundos...${NC}"
    sleep 5
    
    # Ejecutar Windows
    run_windows
    WINDOWS_EXIT=$?
    
    # Resumen final
    echo ""
    echo -e "${BLUE}📊 RESUMEN DE EJECUCIÓN${NC}"
    echo -e "${BLUE}======================${NC}"
    
    if [ $UBUNTU_EXIT -eq 0 ]; then
        echo -e "✅ Ubuntu: Configuración exitosa"
    else
        echo -e "❌ Ubuntu: Error (código $UBUNTU_EXIT)"
    fi
    
    if [ $WINDOWS_EXIT -eq 0 ]; then
        echo -e "✅ Windows: Configuración exitosa"
    else
        echo -e "❌ Windows: Error (código $WINDOWS_EXIT)"
    fi
    
    if [ $UBUNTU_EXIT -eq 0 ] && [ $WINDOWS_EXIT -eq 0 ]; then
        echo -e "${GREEN}🎉 ¡Proyecto completado exitosamente con credenciales seguras!${NC}"
        return 0
    else
        return 1
    fi
}

# Función para ejecutar playbook personalizado
run_custom() {
    local playbook=$1
    local limit=${2:-all}
    
    if [ -z "$playbook" ]; then
        echo -e "${RED}❌ Error: Especifica el playbook a ejecutar${NC}"
        echo "Uso: $0 custom <playbook> [limit]"
        return 1
    fi
    
    echo -e "${GREEN}🔧 Ejecutando playbook personalizado: $playbook${NC}"
    
    ansible-playbook "$playbook" \
        -i inventories/hosts \
        -l "$limit" \
        --vault-password-file "$VAULT_PASSWORD_FILE" \
        -v
    
    return $?
}

# Función para mostrar ayuda
show_help() {
    echo "Uso: $0 [comando] [opciones]"
    echo ""
    echo "Comandos:"
    echo "  ubuntu      - Configurar solo Ubuntu"
    echo "  windows     - Configurar solo Windows"
    echo "  all         - Configurar todo el proyecto"
    echo "  custom      - Ejecutar playbook personalizado"
    echo "  test        - Probar conectividad con vault"
    echo "  help        - Mostrar esta ayuda"
    echo ""
    echo "Ejemplos:"
    echo "  $0 ubuntu"
    echo "  $0 windows"
    echo "  $0 all"
    echo "  $0 custom playbooks/custom.yml ubuntu"
}

test_connectivity() {
    echo -e "${GREEN}🧪 Probando conectividad con credenciales del vault...${NC}"
    
    echo "Probando Ubuntu (localhost):"
    ansible ubuntu -i inventories/hosts -m ping --vault-password-file "$VAULT_PASSWORD_FILE"
    
    echo ""
    echo "Probando Windows (remoto):"
    ansible windows -i inventories/hosts -m win_ping --vault-password-file "$VAULT_PASSWORD_FILE" || echo "No hay hosts Windows configurados"
    
    echo ""
    echo -e "${GREEN}✅ Prueba de conectividad completada${NC}"
}

# Función principal
main() {
    case "${1:-help}" in
        "ubuntu")
            run_ubuntu
            ;;
        "windows")
            run_windows
            ;;
        "all")
            run_all
            ;;
        "custom")
            run_custom "$2" "$3"
            ;;
        "test")
            test_connectivity
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

# Ejecutar función principal
main "$@"
