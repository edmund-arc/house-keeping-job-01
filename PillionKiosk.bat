@echo off
setlocal enabledelayedexpansion

REM Why echo off
REM Set the path to the remote directory
set "directoryPath=C:\temp"
set "destinationRoot=C:\PillionKiosk"

REM Set the number of days for files to be considered old
set "daysOld=1"

REM Calculate yesterday's date in the format "yyyyMMdd"
for /f "delims=" %%a in ('powershell -Command "(Get-Date).AddDays(-%daysOld%).ToString('yyyyMMdd')"') do set "yesterdayDate=%%a"

REM Set the destination folder with yesterday's date
set "destinationFolder=!destinationRoot!\!yesterdayDate!"

REM Get the current date and time in the format "dd/MM/yyyy HH:mm:ss"
for /f "delims=" %%a in ('powershell -Command "Get-Date -Format 'dd/MM/yyyy HH:mm:ss'"') do set "currentDate=%%a"

REM Calculate the date threshold in the format "yyyy-MM-dd HH:mm:ss"
for /f "delims=" %%a in ('powershell -Command "(Get-Date).AddDays(-%daysOld%).ToString('dd/MM/yyyy HH:mm:ss')"') do set "dateThreshold=%%a"

REM Process files in the remote directory and filter based on creation time
for /r "%directoryPath%" %%F in (*) do (
    set "fileCreationTime=%%~tF"
    set "sourceFile=%%F"
    set "relativePath=!sourceFile:%directoryPath%=!"
    set "destPath=!destinationFolder!!relativePath!"

    rem Obtain the parent directory of destPath
    for %%I in ("!destPath!") do set "destPathWithoutLast=%%~dpI"
     
    echo !relativePath!
echo !fileCreationTime!
echo %dateThreshold%
    if "!fileCreationTime!" lss "%dateThreshold%" (
        rem Create the destination subfolder if it doesn't exist
        if not exist "!destPathWithoutLast!" mkdir "!destPathWithoutLast!"

        rem Copy the file to the destination
        copy "%%F" "!destPath!"
		echo lol
		
        REM Optionally, remove the old file
        del "%%F" /Q
    )
)

set "sourceFolder=!destinationRoot!"
set "zipFilePath=!destinationRoot!\!yesterdayDate!.zip"

powershell Compress-Archive -Path "%sourceFolder%" -DestinationPath "%zipFilePath%" -Force

endlocal
