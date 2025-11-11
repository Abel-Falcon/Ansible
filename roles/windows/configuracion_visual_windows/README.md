# Rol: configuracion_visual_windows

Rol de Ansible para personalizar la apariencia de Windows.

## Funciones principales
- Cambia el fondo de pantalla.
- Configura tema claro u oscuro.
- Muestra/oculta archivos y extensiones.
- Muestra segundos en el reloj del sistema.

## Variables principales

| Variable | Descripción | Valor por defecto |
|-----------|--------------|-------------------|
| `fondo_pantalla_url` | URL del fondo a usar | `https://wallpapercave.com/wp/wp1234567.jpg` |
| `tema_windows` | Tema de color (`oscuro` o `claro`) | `oscuro` |
| `mostrar_extensiones` | Mostrar extensiones de archivo | `true` |
| `mostrar_archivos_ocultos` | Mostrar archivos ocultos | `false` |
| `mostrar_segundos_reloj` | Mostrar segundos en reloj | `true` |

## Ejemplo de uso
```yaml
- hosts: windows
  roles:
    - configuracion_visual_windows
