@echo off
REM ============================================================
REM Script para copiar migrations para diretórios de build
REM ============================================================
REM
REM IMPORTANTE: Execute este script sempre que:
REM   - Criar uma nova migration
REM   - Modificar uma migration existente
REM   - Antes de compilar/executar o projeto
REM
REM ============================================================

echo.
echo ============================================================
echo  Copiando Migrations para Diretorios de Build
echo ============================================================
echo.

REM Copia para Win32\Debug
if exist "Win32\Debug\" (
    if not exist "Win32\Debug\Migrations\SQL\" mkdir "Win32\Debug\Migrations\SQL\"
    xcopy /Y /E /I "Migrations\SQL\*.sql" "Win32\Debug\Migrations\SQL\" > nul
    echo - Copiado para Win32\Debug\Migrations\SQL\
)

REM Copia para Win32\Release
if exist "Win32\Release\" (
    if not exist "Win32\Release\Migrations\SQL\" mkdir "Win32\Release\Migrations\SQL\"
    xcopy /Y /E /I "Migrations\SQL\*.sql" "Win32\Release\Migrations\SQL\" > nul
    echo - Copiado para Win32\Release\Migrations\SQL\
)

REM Copia para Win64\Debug
if exist "Win64\Debug\" (
    if not exist "Win64\Debug\Migrations\SQL\" mkdir "Win64\Debug\Migrations\SQL\"
    xcopy /Y /E /I "Migrations\SQL\*.sql" "Win64\Debug\Migrations\SQL\" > nul
    echo - Copiado para Win64\Debug\Migrations\SQL\
)

REM Copia para Win64\Release
if exist "Win64\Release\" (
    if not exist "Win64\Release\Migrations\SQL\" mkdir "Win64\Release\Migrations\SQL\"
    xcopy /Y /E /I "Migrations\SQL\*.sql" "Win64\Release\Migrations\SQL\" > nul
    echo - Copiado para Win64\Release\Migrations\SQL\
)

echo.
echo ============================================================
echo  Migrations copiadas com sucesso!
echo ============================================================
echo.
echo Agora voce pode compilar e executar o projeto.
echo As migrations serao aplicadas automaticamente.
echo.
pause
exit /b 0