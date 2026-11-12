@echo off
setlocal

set "ROOT=%~dp0"
set "DOME=%ROOT%lib\dome-windows-x64\dome.exe"
set "OUTPUT=%ROOT%dist"

if not exist "%DOME%" (
  echo DOME executable not found: "%DOME%"
  exit /b 1
)

if not exist "%ROOT%src\main.wren" (
  echo Game entry point not found: "%ROOT%src\main.wren"
  exit /b 1
)

if not exist "%OUTPUT%" mkdir "%OUTPUT%"
if errorlevel 1 (
  echo Could not create output folder: "%OUTPUT%"
  exit /b 1
)

pushd "%ROOT%src"
if errorlevel 1 (
  echo Could not open the game source folder.
  exit /b 1
)

"%DOME%" nest main.wren room.wren door.wren
if errorlevel 1 (
  popd
  echo DOME could not bundle the game source.
  exit /b 1
)

popd
"%DOME%" fuse "%ROOT%src\game.egg" "%OUTPUT%\ButtonOfSigns.exe"
if errorlevel 1 (
  echo DOME could not create the standalone executable.
  exit /b 1
)

echo Standalone game created: "%OUTPUT%\ButtonOfSigns.exe"
exit /b 0
