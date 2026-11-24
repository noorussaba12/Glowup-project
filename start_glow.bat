@echo off
title Glow AI Skin Health App Launcher
echo ===================================================
echo     ✨ Launching Glow AI Skin Health App ✨
echo ===================================================
echo.

cd /d "%~dp0\glow_backend"
echo [1/2] Starting Node.js Backend Server on port 5000...
start "Glow AI Backend" cmd /k "npm start"

timeout /t 3 /nobreak >nul

echo [2/2] Opening Interactive Mobile Simulator in your browser...
start "" "%~dp0\glow_web_preview\index.html"

echo.
echo Glow is now running!
echo - Backend: http://localhost:5000/api/health
echo - Web Preview: Opened in your default browser
echo.
pause
