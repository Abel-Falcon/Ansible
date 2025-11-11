# Rol: software_windows

Automatiza la instalación y actualización de programas en Windows 10/11 usando Ansible.

## Funcionalidades:
- Instala Chocolatey si no está presente.
- Instala programas definidos en `software_choco_paquetes`.
- Permite agregar instaladores manuales con `software_win_paquetes`.
- Actualiza todos los paquetes cuando `software_actualizar_choco` es true.

## Variables principales:
- `software_choco_paquetes`: lista de programas Chocolatey.
- `software_win_paquetes`: lista de instaladores `.exe` o `.msi` personalizados.
- `software_actualizar_choco`: controla si se actualiza todo.
