Installing Windows 10 and Linux using EFI on an ASUS 5750G.

This wasn't trivial, first I had to install Linux to a USB stick.
Grab QEMU, as root attach the whole hard drive (sda) and attach the USB 
stick I had prepared with Windows 10 to then boot and install virtually, 
I used 'virt-manager' to get the job done. I'm sure there is a way 
to boot from EFI on USB using this unlocked BIOS, but it surely would
not when i tried. 

After installing Windows 10 virtually on a physical harddrive, all was 
smooth. It booted straight up setting the BIOS to 'EFI first' and all.
Then came the time for Linux, and it turns out the default variables
are hardcoded in the BIOS, this is where the script comes along. 
