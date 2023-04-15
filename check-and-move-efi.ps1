Write-Output "Workaround read only NVRAM or in my case a hacked bios with hardcoded defaults and an early EFI" 
pause

if (-not (Test-Path "W:\EFI\Microsoft\Boot\bootmgfw.efi")) {
Write-Output "Mounting EFI to W:"
mountvol w: /S
}

if (-not (Test-Path "W:\EFI\Microsoft\Boot\bootmgfww.efi")) {
Write-Output "EFI\Microsoft\Boot\bootmgfww.efi not found."
}

$msefi = 'W:\EFI\Microsoft\Boot\bootmgfw.efi'
$checkforstring = (Get-ChildItem -Path $msefi| Select-Object -First 1).fullname
if ($checkforstring) {
    $checkforstring
    $search = (Get-Content $checkforstring | Select-String -Pattern 'Microsoft Corporation').Matches.Success
    if($search){
        Write-output "$msefi contians the string Microsoft Corporation moving proceeding"
        cp W:\EFI\Microsoft\Boot\bootmgfw.efi W:\EFI\Microsoft\Boot\bootmgfww.efi
    } else {
        Write-output "$msefi does not contians the string Microsoft Corporation moving aborting"
        pause 
        break
    }
} else {
    "No file: $msefi"
}

write-output "Locating grubx64.efi and path"

$grubfileocation = Get-ChildItem –Path W:\EFI -include grubx64.efi -Force -Recurse |
    ? FullName -notLike 'W:\EFI\Microsoft\Boot\grubx64.efi' |
        Get-ChildItem -File -Force |
            select-object -Expand FullName
$grubfileocation 

$grubpwd = Split-Path -Path "$grubfileocation" -Parent
write-output "GRUB location: $grubpwd"

if((Get-FileHash $grubfileocation).hash  -ne (Get-FileHash W:\EFI\Microsoft\Boot\bootmgfw.efi).hash) {
Write-Output $grubfileocation is not the bootmgfw.efi
 cp $grubpwd W:\EFI\Microsoft\Boot\
} else { 
Write-Output "$grubfileocation is the bootmgfw.efi"
}

if((Get-FileHash $grubfileocation).hash  -ne (Get-FileHash W:\EFI\Microsoft\Boot\grubx64.efi).hash) {
Write-Output "$grubfileocation is not the same as W:\EFI\Microsoft\Boot\grubx64.efi"
 cp $grubpwd W:\EFI\Microsoft\Boot\
} else { 
Write-Output "$grubfileocation is and W:\EFI\Microsoft\Boot\grubx64.efi are the same file" 
}

if (-not (Test-Path "W:\EFI\Microsoft\Boot\grubx64.efi")) {
Write-Output "EFI\Microsoft\Boot\grubx64.efi not found! Coptying $gruppwd to W:\EFI\Microsoft\Boot\"
 cp $gruppwd W:\EFI\Microsoft\Boot\
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

function CompareHashFiles() {

if((Get-FileHash $hashfile).hash  -ne (Get-FileHash $hashfilenew).hash) {
write-output "EFI files are different "
cp W:\EFI\Microsoft\Boot\bootmgfw.efi W:\EFI\Microsoft\Boot\bootmgfww.efi
cp W:\EFI\Microsoft\Boot\grubx64.efi W:\EFI\Microsoft\Boot\bootmgfw.efi
cp $hashfileout $hashfile
} else {
Write-output  "EFI files are the same"
  }

}

CompareHashFiles

Write-Output "All should be well"
pause