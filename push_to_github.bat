@echo off
title Push Glow App to GitHub (Glowup-project)
cd /d "C:\Users\Admin\Desktop\Glow up"
echo ===============================================================
echo Pushing project to https://github.com/noorussaba12/Glowup-project.git
echo ===============================================================
echo.
git push -u origin main
echo.
echo ===============================================================
if %ERRORLEVEL% EQU 0 (
    echo SUCCESS: Project has been pushed to GitHub!
) else (
    echo Push incomplete.
)
echo ===============================================================
echo.
pause
