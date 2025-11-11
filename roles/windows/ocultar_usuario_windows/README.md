# Rol: ocultar_usuarios_windows

Este rol permite ocultar usuarios específicos del menú de inicio de sesión en sistemas Windows.

## Funciones principales
- Modifica el registro de Windows para ocultar cuentas definidas.
- Permite definir la lista de usuarios a ocultar mediante `usuarios_ocultos`.

## Variables principales

| Variable | Descripción | Valor por defecto |
|-----------|--------------|-------------------|
| `usuarios_ocultos` | Lista de usuarios a ocultar | `['Administrador', 'Invitado', 'tech', 'security']` |
| `ruta_registro_ocultar` | Clave del registro usada para ocultar cuentas | `HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList` |

## Ejemplo de uso
```yaml
- hosts: windows
  roles:
    - ocultar_usuarios_windows
