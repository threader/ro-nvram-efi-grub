ro-nvram-efi-grub 0.02


This is meant to solve a problem with read only NVRAM's where GRUB can't be set as default, or in my case a 2010ish laptop with a hardcoded hacked and unlocked BIOS that normally didn't support EFI untill said BIOS, my solution was to edit the os-prober script (/usr/lib/os-probes/mounted/efi/20microsoft : bootmgfw=$(item_in_dir bootmgfw.efi "$efi/$microsoft/$boot") to search for bootmgfww.efi instead and move EFI/Microsoft/Boot/bootmgfw.efi there, copy /boot/EFI/debian/* to /boot/EFI/Microsoft/Boot/ and copy grubx64.efi to bootmgfw.efi. 

Also a great way for me to learn some PowerShell :) - Linux user since 1999 <3'ed Slackware back/since then so this Windows stuff is equal to runes in Himinbjörg for me now as is probably quite evident from the the way this script is written.

What you need to do:
--
Run the file "run-this.cmd" - with an internet conntection as it downloads NSudo.
--

TODO:
Add Secure Boot Signed and unsigned support. again...( thank you hibernated linux and ntfs-3g or whatever happened) # Done
Maybe add 32bit? # Done
Search for the *.efi files and compare/update grub64.efi while at it. # Done 
"or edited by you to do so." # Done
Check if W:\ is actually available?
Find where i put that sweet Acer 5750 BIOS i dug trough the entire intwerweb's to find once learning about. #Done
