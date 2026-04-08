@echo off
:: ============================================================
:: UCPP — Daily Craigslist Scraper
:: Run this file manually or via Windows Task Scheduler.
::
:: To set up Task Scheduler (run once in an admin terminal):
::   schtasks /create /tn "UCPP Daily Scrape" ^
::     /tr "\"W:\Personal Projects\UCPP\run_scraping_script.bat\"" ^
::     /sc DAILY /st 02:00 /ru "%USERNAME%" /f
::
:: To view the scheduled task:
::   schtasks /query /tn "UCPP Daily Scrape"
::
:: To delete it:
::   schtasks /delete /tn "UCPP Daily Scrape" /f
:: ============================================================

set PROJECT_ROOT=W:\Personal Projects\UCPP
set VENV=%PROJECT_ROOT%\ucppvenv
set SCRIPT=%PROJECT_ROOT%\Notebooks\Scraping\scraping.py
set LOG_DIR=%PROJECT_ROOT%\Notebooks\Scraping

:: Activate the virtual environment
call "%VENV%\Scripts\activate.bat"
if errorlevel 1 (
    echo ERROR: Could not activate venv at %VENV%
    exit /b 1
)

:: Run the scraper (all cities, full run)
echo [%DATE% %TIME%] Starting UCPP scraper...
python "%SCRIPT%"

if errorlevel 1 (
    echo [%DATE% %TIME%] Scraper exited with errors. Check logs in %LOG_DIR%
    exit /b 1
)

echo [%DATE% %TIME%] Scraper completed successfully.

:: Optional: uncomment to call the Flask reload endpoint after scraping
:: curl -s http://localhost:5000/api/nhtsa-reload > nul

exit /b 0
