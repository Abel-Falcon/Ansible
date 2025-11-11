# Rol: actualiza_windows

Automatiza la búsqueda, instalación y limpieza de actualizaciones en Windows.

## Funciones principales:
- Búsqueda de actualizaciones críticas y de seguridad.
- Instalación automática.
- Limpieza de componentes antiguos con DISM.
- Reinicio automático opcional.
- Registro detallado del proceso en `C:\Logs\actualizacion_windows.log`.

## Variables principales:
| Variable | Descripción | Valor por defecto |
|-----------|-------------|------------------|
| `actualiza_categorias` | Categorías de actualizaciones a instalar | `[SecurityUpdates, CriticalUpdates, UpdateRollups]` |
| `actualiza_estado` | Acción sobre las actualizaciones (`installed`, `searched`) | `installed` |
| `actualiza_reiniciar` | Reinicia el sistema si es necesario | `true` |
| `actualiza_limpiar_antiguas` | Limpia componentes antiguos tras actualizar | `true` |
| `actualiza_log` | Ruta del log de actualizaciones | `C:\Logs\actualizacion_windows.log` |
