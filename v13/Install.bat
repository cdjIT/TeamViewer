setlocal

REM To add the PC to a TeamViewer group add the Configuration ID and API
REM Token as parameters after this batch file  in that order e.g.
REM Install.cmd xyz123 2111892-RotUbuml0D0vK2p625

REM If running as a Naverisk script add Configuration ID and API Token
REM into Script Parameters field e.g. xyz123 2111892-RotUbuml0D0vK2p625

REM This will also remove any older TeamViewer installs

REM *********************************************************************
REM Environment customization begins here. Modify variables below.
REM *********************************************************************
 
REM Get ProductName  
set ProductName=TeamViewer

REM Get Display Version
set DisplayVersion=13.0
 
REM Set Executable Name
set Executable=TeamViewer_Host_Setup.exe
 
REM Set TeamViewer Registry Settings
set Settings=TeamViewer_Settings_13.reg

REM Set TeamViewer Assignment Executable Name
set Assignment=TeamViewer_Assignment.exe
 
REM Set LogLocation to a central directory to collect log files.
set LogLocation=%temp%
 
 
REM *********************************************************************
REM Deployment code begins here. Do not modify anything below this line.
REM *********************************************************************
 
IF NOT "%ProgramFiles(x86)%"=="" (goto ARP64) else (goto ARP86)
 
REM Operating system is X64. Check for 32 bit application in emulated Wow6432 uninstall key
:ARP64
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432NODE\Microsoft\Windows\CurrentVersion\Uninstall\%ProductName%" /v DisplayVersion | find "%DisplayVersion%"
if NOT %errorlevel%==1 (goto End)
 
REM Check for 32 and 64 bit versions of application in regular uninstall key.(Application 64bit would also appear here on a 64bit OS) 
:ARP86
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%ProductName%" /v DisplayVersion | find "%DisplayVersion%"
if %errorlevel%==1 (goto DeployTV) else (goto End)
 
REM If 1 returned, the product was not found. Run setup here.

:DeployTV
echo echo %date% %time% Uninstall triggered on %computername%.>> %LogLocation%\%ProductName%.txt
Net stop Teamviewer
"%ProgramFiles(x86)%\TeamViewer\Version6\uninstall.exe" /S
"%ProgramFiles(x86)%\TeamViewer\Version7\uninstall.exe" /S
"%ProgramFiles(x86)%\TeamViewer\Version8\uninstall.exe" /S
"%ProgramFiles(x86)%\TeamViewer\Version9\uninstall.exe" /S
"%ProgramFiles(x86)%\TeamViewer\uninstall.exe" /S

echo %date% %time% Deployment triggered on %computername%.>> %LogLocation%\%ProductName%.txt
echo echo %date% %time% Copy Executable and add Config ID %computername%.>> %LogLocation%\%ProductName%.txt
copy %Executable% TeamViewer_Host_Setup-idc%1.exe

echo echo %date% %time% Start TeamViewer Install %computername%.>> %LogLocation%\%ProductName%.txt
start /wait TeamViewer_Host_Setup-idc%1.exe /S
echo %date% %time% Setup executed and ended with error code %errorlevel%. >> %LogLocation%\%computername%.txt

echo echo %date% %time% Run TeamViewer Assignment %computername%.>> %LogLocation%\%ProductName%.txt
%Assignment% -apitoken %2 -datafile "%ProgramFiles(x86)%\TeamViewer\AssignmentData.json" -verbose -devicealias %computername%
Timeout 5
Net stop Teamviewer

echo echo %date% %time% Add TeamViewer Settings %computername%.>> %LogLocation%\%ProductName%.txt
net stop Teamviewer
REGEDIT.EXE  /S  %Settings%
net start Teamviewer
del TeamViewer_Host_Setup-idc%1.exe
 
REM If 0 or other was returned, the product was found or another error occurred. Do nothing.
:End
 
Endlocal