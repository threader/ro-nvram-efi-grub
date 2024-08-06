
set "usedir=%HOMEDRIVE%%HOMEPATH%\Desktop\ro-nvram-efi-grub"
set "powshcmd=PowerShell -WindowStyle Normal"

IF "%PROCESSOR_ARCHITECTURE%"=="AMD64" (set nsarchbit=x64
) ELSE (set nsarchbit=Win32)

set "powshadmcmd=%powshcmd% "start-process "powershell -Wait -Verb RunAS""

echo "Flipping Setting ExecutionPolicy back and forth then running %usedir%\check-and-move-efi.ps1"
%powshadmcmd% %powshcmd% "Set-ExecutionPolicy -ExecutionPolicy Bypass"
:: %admuser% %powshcmd% Start-process powershell -Verb RunAS -File %usedir%\check-and-move-efi.ps1
%powshadmcmd% %powshcmd% -File %usedir%\check-and-move-efi.ps1
%powshadmcmd% %powshcmd% "Set-ExecutionPolicy -ExecutionPolicy Restricted"
pause
