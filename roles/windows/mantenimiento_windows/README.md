# Rol: mantenimiento_windows

Automatiza tareas de mantenimiento preventivo y correctivo en sistemas Windows.

## Funcionalidades principales:
- Limpieza de temporales.
- Comprobación de archivos del sistema (SFC).
- Verificación y reparación de disco (CHKDSK).
- Detección de actualizaciones pendientes.
- Generación de log detallado de mantenimiento.

## Variables configurables:
- `mant_limpiar_disco`: limpia temporales.
- `mant_comprobar_sistema`: ejecuta SFC /scannow.
- `mant_comprobar_disco`: ejecuta CHKDSK /F /R.
- `mant_verificar_actualizaciones`: busca actualizaciones críticas.
- `mant_generar_reporte`: crea un log en `C:\Logs`.
- `mant_reiniciar_si_necesario`: reinicia el sistema al finalizar.
