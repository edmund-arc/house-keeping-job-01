@echo off
setlocal enabledelayedexpansion

REM Set the path to the directory
set "directoryPath=\\192.168.1.11\c\temp"
set "destinationFolder=C:\RiderKiosk"

REM Set the number of days for files to be considered old
set "daysOld=1"

REM Get the current date
for /f "delims=" %%a in ('powershell -Command "Get-Date -Format 'dd/MM/yyyy HH:mm:ss'"') do set "currentDate=%%a"

REM Calculate the date threshold in the format "yyyy-MM-dd HH:mm:ss"
for /f "delims=" %%a in ('powershell -Command "(Get-Date).AddDays(-%daysOld%).ToString('dd/MM/yyyy HH:mm:ss')"') do set "dateThreshold=%%a"

REM Process files in the directory and filter based on creation time
for /r "%directoryPath%" %%F in (*) do (
    set "fileCreationTime=%%~tF"
    set "sourceFile=%%F"
    set "relativePath=!sourceFile:%directoryPath%=!"
    set "destPath=%destinationFolder%!relativePath!"


        rem Obtain the parent directory of destPath
        for %%I in ("!destPath!") do set "destPathWithoutLast=%%~dpI"
         
        echo !destPathWithoutLast!

        if "!fileCreationTime!" lss "%dateThreshold%" (
        rem Create the destination subfolder if it doesn't exist
                if not exist "!destPathWithoutLast!" mkdir "!destPathWithoutLast!"

        rem Copy the file to the destination
                copy "%%F" "!destPath!"


        REM Optionally, remove the old file
        del "%%F" /Q
    )
)

set "sourceFolder=C:\RiderKiosk"
set "zipFilePath=C:\RiderKiosk.zip"

powershell Compress-Archive -Path "%sourceFolder%" -DestinationPath "%zipFilePath%" -Force


endlocal
exit