@echo off
title Push Glow App to GitHub
cd /d "C:\Users\Admin\Desktop\Glow up"
echo ===============================================================
echo Pushing project to https://github.com/noorussaba12/skin-glow.git
echo ===============================================================
echo.
git push -u origin main
echo.
echo ===============================================================
if %ERRORLEVEL% EQU 0 (
    echo SUCCESS: Project has been pushed to GitHub!
) else (
    echo Push incomplete. If prompted, please sign in via browser.
)
echo ===============================================================
echo.
pause
