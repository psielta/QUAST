@echo off
echo Testando compilação do projeto Quast...
echo.

REM Tenta encontrar o compilador Delphi
set DCC32=
if exist "C:\Program Files (x86)\Embarcadero\Studio\22.0\bin\dcc32.exe" (
    set DCC32="C:\Program Files (x86)\Embarcadero\Studio\22.0\bin\dcc32.exe"
) else if exist "C:\Program Files (x86)\Embarcadero\Studio\21.0\bin\dcc32.exe" (
    set DCC32="C:\Program Files (x86)\Embarcadero\Studio\21.0\bin\dcc32.exe"
) else if exist "C:\Program Files (x86)\Embarcadero\Studio\20.0\bin\dcc32.exe" (
    set DCC32="C:\Program Files (x86)\Embarcadero\Studio\20.0\bin\dcc32.exe"
) else if exist "C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\dcc32.exe" (
    set DCC32="C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\dcc32.exe"
) else (
    echo Compilador Delphi não encontrado.
    echo Por favor, compile o projeto no RAD Studio para verificar erros.
    pause
    exit /b 1
)

echo Usando compilador: %DCC32%
echo.

%DCC32% -B Quast.dpr

if %ERRORLEVEL% EQU 0 (
    echo.
    echo Compilação bem-sucedida!
) else (
    echo.
    echo Erros encontrados durante a compilação.
    echo Por favor, verifique os erros acima.
)

pause