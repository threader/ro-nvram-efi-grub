ro-nvram-efi-grub 0.00

The script has to be run once as per now after everything is set up from Linux to get the $hashfileout written to $efi,
or edited by you to do so.

This is meant to solve a problem with read only NVRAM's where GRUB or so can't be the default, or in my case a 2010 laptop with a hardcoded hacked and unlocked bios that normally didn't support EFI untill said bios, my solution was to edit the os-prober script (/usr/lib/os-probes/mounted/efi/20microsoft : bootmgfw=$(item_in_dir bootmgfw.efi "$efi/$microsoft/$boot") to search for bootmgfww.efi instead and move EFI/Microsoft/Boot/bootmgfw.efi there, copy /boot/EFI/debian/* to /boot/EFI/Microsoft/Boot/ and copy grubx64.efi to bootmgfw.efi. 

Also a great way for me to learn some PowerShell :) - Linux user since 1999 <3'ed Slackware back/since then so this Windows stuff is equal to runes in Himinbjörg for me now as is probably quite evident from the the way this script is written.

TODO / you need to do:
--
I will probably bother solving this with a .cmd script next time i look at this
To run the script, you must in Powershell allow scripts:
Set-ExecutionPolicy -ExecutionPolicy Bypass
check-and-move-efi.ps1
Set-ExecutionPolicy -ExecutionPolicy Restricted
--
Search for the *.efi files and compare/update grub64.efi while at it.
"or edited by you to do so."
Check if W:\ is actually available?
Find where i put that sweet bios i dug trough the entire intwerweb's to find once learning about.