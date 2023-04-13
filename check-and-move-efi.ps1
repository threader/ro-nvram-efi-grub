Write-Output "Workaround read only NVRAM or in my case a hacked bios with hardcoded defaults and an early EFI" 
pause

if (-not (Test-Path "W:\EFI\Microsoft\Boot\bootmgfw.efi")) {
Write-Output "Mounting EFI to W:"
mountvol w: /S
} 

if (-not (Test-Path "W:\EFI\Microsoft\Boot\bootmgfww.efi")) {
Write-Output "EFI\Microsoft\Boot\bootmgfww.efi not found, the Windows bootmgfw.efi should be moved to bootmgfww.efi and also replaced by grub64.efi and your /usr/lib/os-probes/mounted/efi/20microsoft edited to bootmgfww.efi!"
pause
break
}

if (-not (Test-Path "W:\EFI\Microsoft\Boot\grubx64.efi")) {
Write-Output "EFI\Microsoft\Boot\grubx64.efi not found, jump to linux and copy /boot/EFI/debian/* to /boot/EFI/Microsoft/Boot/ . RTFM!"
pause
break
}

Write-Output "MD5 compare W:\EFI\Microsoft\Boot\*.efi" 


$hashfile = "W:\hash.output.txt"
$hashfilenew = "W:\hash.output.new.txt"

if (Test-Path -Path $hashfile) {
$hashfileout = $hashfilenew
        } else {
$hashfileout = $hashfile
        }

Write-Output "Writing file to: $hashfileout"

function md5hashefi() {
$EfiFilePath = "W:\EFI\Microsoft\Boot\bootmgfww.efi"
$md5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
$hash = [System.BitConverter]::ToString($md5.ComputeHash([System.IO.File]::ReadAllBytes($EfiFilePath))).Replace("-","")

Write-Output $hash
Out-File -FilePath $hashfileout -InputObject $hash


$EfiFilePath = "W:\EFI\Microsoft\Boot\bootmgfw.efi"
$hash = [System.BitConverter]::ToString($md5.ComputeHash([System.IO.File]::ReadAllBytes($EfiFilePath))).Replace("-","")

Write-Output $hash
Out-File -FilePath $hashfileout -InputObject $hash -Append


$EfiFilePath = "W:\EFI\Microsoft\Boot\grubx64.efi"
$hash = [System.BitConverter]::ToString($md5.ComputeHash([System.IO.File]::ReadAllBytes($EfiFilePath))).Replace("-","")

Write-Output $hash
Out-File -FilePath $hashfileout -InputObject $hash -Append

}

md5hashefi

function CompareTwoFiles() {

if((Get-FileHash $hashfile).hash  -ne (Get-FileHash $hashfilenew).hash) 
write-output "EFI files are different"
cp W:\EFI\Microsoft\Boot\bootmgfw.efi W:\EFI\Microsoft\Boot\bootmgfww.efi
cp W:\EFI\Microsoft\Boot\grubx64.efi W:\EFI\Microsoft\Boot\bootmgfw.efi
cp $hashfileout $hashfile
} else {
Write-output  "EFI files are the same"
  }

}

CompareTwoFiles