ro-nvram-efi-grub 0.01


This is meant to solve a problem with read only NVRAM's where GRUB or so can't be the default, or in my case a 2010 laptop with a hardcoded hacked and unlocked bios that normally didn't support EFI untill said bios, my solution was to edit the os-prober script (/usr/lib/os-probes/mounted/efi/20microsoft : bootmgfw=$(item_in_dir bootmgfw.efi "$efi/$microsoft/$boot") to search for bootmgfww.efi instead and move EFI/Microsoft/Boot/bootmgfw.efi there, copy /boot/EFI/debian/* to /boot/EFI/Microsoft/Boot/ and copy grubx64.efi to bootmgfw.efi. 

Also a great way for me to learn some PowerShell :) - Linux user since 1999 <3'ed Slackware back/since then so this Windows stuff is equal to runes in Himinbjörg for me now as is probably quite evident from the the way this script is written.

you need to do:
--
run the file run-this.cmd - with an internet conntection as it downloads NSudo.
--

TODO:
Search for the *.efi files and compare/update grub64.efi while at it. # DONE 
"or edited by you to do so." # DONE
Check if W:\ is actually available?
Find where i put that sweet bios i dug trough the entire intwerweb's to find once learning about.