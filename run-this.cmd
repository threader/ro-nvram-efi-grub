
set "usedir=%HOMEDRIVE%%HOMEPATH%\Desktop\ro-nvram-efi-grub"
set "powshcmd=PowerShell -WindowStyle Normal"

IF "%PROCESSOR_ARCHITECTURE%"=="AMD64" (set nsarchbit=x64
) ELSE (set nsarchbit=Win32)

set "admuser=%usedir%\usr\bin\Nsudo\%nsarchbit%\NSudoLC.exe -UseCurrentConsole -Priority:AboveNormal -M:S -U:S -P:E --wait"

if exist %usedir%\usr\bin\Nsudo\%nsarchbit%\NSudoLG.exe goto skipnsudo
echo "Downloading NSudo to %usedir%"
%powshcmd% "Invoke-WebRequest -uri https://github.com/M2TeamArchived/NSudo/releases/download/9.0-Preview1/NSudo_9.0_Preview1_9.0.2676.0.zip -OutFile %usedir%\Nsudo.zip"
%powshcmd% "Expand-Archive -Force '%usedir%\Nsudo.zip' '%usedir%\usr\bin\Nsudo'"
:skipnsudo

echo "Flipping Setting ExecutionPolicy back and forth then running %usedir%\check-and-move-efi.ps1"
%admuser% %powshcmd% "Set-ExecutionPolicy -ExecutionPolicy Bypass"
:: %admuser% %powshcmd% Start-process powershell -Verb RunAS -File %usedir%\check-and-move-efi.ps1
%admuser% %powshcmd% -File %usedir%\check-and-move-efi.ps1
%admuser% %powshcmd% "Set-ExecutionPolicy -ExecutionPolicy Restricted"
pause