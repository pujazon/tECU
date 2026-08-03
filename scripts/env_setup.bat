@echo off
setlocal enabledelayedexpansion

set CFG_FILE=%~dp0local_env.cfg

:: Verify if the local configuration file exists
if not exist "%CFG_FILE%" (
    echo [ERROR] Could not find scripts\local_env.cfg
    echo [INFO] Copy scripts\local_env.cfg.template to scripts\local_env.cfg and set your paths.
    exit /b 1
)

echo [tECU] Loading configuration from local_env.cfg...

:: Parse the .cfg file ignoring empty lines and comments (#)
for /f "usebackq tokens=1,* delims==" %%A in ("%CFG_FILE%") do (
    set "LINE=%%A"
    if not "!LINE:~0,1!"=="#" (
        if not "%%A"=="" (
            set "%%A=%%B"
        )
    )
)

:: Export the parsed variables to the user environment (CMD)
endlocal & (
    set "ARM_GCC_PATH=%ARM_GCC_PATH%"
    set "MAKE_PATH=%MAKE_PATH%"
    set "STLINK_PATH=%STLINK_PATH%"
    set "LIBUSB_PATH=%LIBUSB_PATH%"
)

:: Apply paths to current session PATH
if defined ARM_GCC_PATH set "PATH=%ARM_GCC_PATH%;%PATH%"
if defined MAKE_PATH set "PATH=%MAKE_PATH%;%PATH%"
if defined STLINK_PATH set "PATH=%STLINK_PATH%;%PATH%"
if defined LIBUSB_PATH set "PATH=%LIBUSB_PATH%;%PATH%"
if defined ST_FLASH_PATH set "PATH=%ST_FLASH_PATH%;%PATH%"

:: Optional alias for 'make'
doskey make=mingw32-make $*

echo [tECU] Environment loaded successfully.
echo --------------------------------------------------
arm-none-eabi-g++ --version | findstr /C:"arm-none-eabi-g++"
echo --------------------------------------------------
