@echo off
setlocal enabledelayedexpansion

set CFG_FILE=%~dp0local_env.cfg

:: Verificar si existe el archivo de configuración local
if not exist "%CFG_FILE%" (
    echo [ERROR] No se encontro el archivo scripts\local_env.cfg
    echo [INFO] Copia scripts\local_env.cfg.template a scripts\local_env.cfg y configura tus rutas.
    exit /b 1
)

echo [tECU] Cargando configuracion desde local_env.cfg...

:: Parsear el archivo .cfg ignorando lineas vacias y comentarios (#)
for /f "usebackq tokens=1,* delims==" %%A in ("%CFG_FILE%") do (
    set "LINE=%%A"
    if not "!LINE:~0,1!"=="#" (
        if not "%%A"=="" (
            set "%%A=%%B"
        )
    )
)

:: Exportar las variables leidas al entorno del usuario (CMD)
endlocal & (
    set "ARM_GCC_PATH=%ARM_GCC_PATH%"
    set "MAKE_PATH=%MAKE_PATH%"
)

:: Aplicar las rutas al PATH de la sesión actual
if defined ARM_GCC_PATH set "PATH=%ARM_GCC_PATH%;%PATH%"
if defined MAKE_PATH set "PATH=%MAKE_PATH%;%PATH%"

:: Alias opcional para 'make'
doskey make=mingw32-make $*

echo [tECU] Entorno cargado con exito.
echo --------------------------------------------------
arm-none-eabi-g++ --version | findstr /C:"arm-none-eabi-g++"
echo --------------------------------------------------