
set "usedir=%HOMEDRIVE%%HOMEPATH%\Desktop\ro-nv-efi-grub"
set "powshcmd=PowerShell -WindowStyle Normal"
set "admuser=%usedir%\bin\Nsudo\%nsarchbit%\NSudoLC.exe -UseCurrentConsole -Priority:AboveNormal -M:S -U:S -P:E --wait"

if exist %usedir%\bin\Nsudo\%nsarchbit%\NSudoLG.exe goto skipnsudo
echo "Downloading NSudo to %usedir%"
%powshcmd% "Invoke-WebRequest -uri https://github.com/M2Team/NSudo/releases/download/9.0-Preview1/NSudo_9.0_Preview1_9.0.2676.0.zip -OutFile %usedir%\Nsudo.zip"
%powshcmd% "Expand-Archive -Force '%usedir%\Nsudo.zip' '%usedir%\bin\Nsudo'"
:skipnsudo

echo "Setting ExecutionPolicy and running %cd%\check-and-move-efi.ps1"
%admuser% %powshcmd% "Set-ExecutionPolicy -ExecutionPolicy Bypass"
powershell Start-process powershell -Verb RunAS  %cd%\check-and-move-efi.ps1
%admuser% %powshcmd% "Set-ExecutionPolicy -ExecutionPolicy Restricted"
pause