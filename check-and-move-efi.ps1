Write-Output "Workaround read only NVRAM or in my case a hacked BIOS with hardcoded defaults and an early version EFI" 
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
        Write-output "$msefi contians the string Microsoft Corporation proceeding."
        cp W:\EFI\Microsoft\Boot\bootmgfw.efi W:\EFI\Microsoft\Boot\bootmgfw.efi.bak
        cp W:\EFI\Microsoft\Boot\bootmgfw.efi W:\EFI\Microsoft\Boot\bootmgfww.efi
    } else {
        Write-output "$msefi does not contians the string Microsoft Corporation moving aborting"
        pause 
       break
    }
} else {
    "No file: $msefi"
}

write-output "Located grub*.efi and path:"

$GrubEfiFileLoc = Get-ChildItem –Path W:\EFI -include grubx64.efi*,grubia32.efi* -Force -Recurse |
    ? FullName -notLike 'W:\EFI\Microsoft\Boot\grubx64.efi*' |
        ? FullName -notLike 'W:\EFI\Microsoft\Boot\grubia32.efi*' |
        Get-ChildItem -File -Force |
            select-object -Expand FullName
$GrubEfiFileLoc 

$GrubPwd = Split-Path -Path "$GrubEfiFileLoc" -Parent
write-output "GRUB location: $GrubPwd"


if (Test-Path "$GrubPwd\grubia32.efi*") {

$MsGrubEfiLoc = "W:\EFI\Microsoft\Boot\grubia32.efi"
write-output "GRUB EFI is 32bit using: $MsGrubEfiLoc"
} else {
$MsGrubEfiLoc = "W:\EFI\Microsoft\Boot\grubx64.efi"
write-output "GRUB EFI is 64bit using: $MsGrubEfiLoc"
}

if((Get-FileHash $GrubEfiFileLoc).hash  -ne (Get-FileHash W:\EFI\Microsoft\Boot\bootmgfw.efi).hash) {
Write-Output "$GrubEfiFileLoc is not the bootmgfw.efi"
 cp $GrubPwd W:\EFI\Microsoft\Boot\
} else { 
Write-Output "$GrubEfiFileLoc is the bootmgfw.efi"
}

if((Get-FileHash $GrubEfiFileLoc).hash  -ne (Get-FileHash $MsGrubEfiLoc).hash) {
Write-Output "$GrubEfiFileLoc is not the same as $MsGrubEfiLoc"
 cp $GrubPwd W:\EFI\Microsoft\Boot\
} else { 
Write-Output "$GrubEfiFileLoc is and $MsGrubEfiLoc are the same file" 
}

if (-not (Test-Path $MsGrubEfiLoc)) {
Write-Output "$MsGrubEfiLoc not found! Coptying $gruppwd to W:\EFI\Microsoft\Boot\"
cp $GrubPwd W:\EFI\Microsoft\Boot\
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


$EfiFilePath = "$MsGrubEfiLoc"
$hash = [System.BitConverter]::ToString($md5.ComputeHash([System.IO.File]::ReadAllBytes($EfiFilePath))).Replace("-","")

Write-Output $hash
Out-File -FilePath $hashfileout -InputObject $hash -Append

}

md5hashefi

function CompareHashFiles() {

if((Get-FileHash $hashfile).hash  -ne (Get-FileHash $hashfilenew).hash) {
write-output "EFI files are different replacing changed EFI files"

if((Get-FileHash W:\EFI\Microsoft\Boot\bootmgfw.efi).hash  -ne (Get-FileHash  W:\EFI\Microsoft\Boot\bootmgfww.efi).hash) {
cp W:\EFI\Microsoft\Boot\bootmgfw.efi W:\EFI\Microsoft\Boot\bootmgfww.efi
}

if((Get-FileHash $MsGrubEfiLoc).hash  -ne (Get-FileHash W:\EFI\Microsoft\Boot\bootmgfw.efi).hash) {
cp $MsGrubEfiLoc W:\EFI\Microsoft\Boot\bootmgfw.efi
}

cp $hashfileout $hashfile

} else {
Write-output  "EFI files are the same"
  }

}
CompareHashFiles

Write-Output "All should be well"
pause
