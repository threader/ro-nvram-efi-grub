Write-Output "Workaround read only NVRAM or in my case a hacked BIOS with hardcoded defaults and an early version EFI" 
pause

if (-not (Test-Path "W:\EFI\Microsoft\Boot\bootmgfw.efi")) {
Write-Output "Mounting EFI to W:"
mountvol w: /S
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

Write-Output "MD5 compare W:\EFI\Microsoft\Boot\*.efi" 

$hashfile = "W:\hash.output.txt"
$hashfilenew = "W:\hash.output.new.txt"

if (Test-Path -Path $hashfile) {
$hashfileout = $hashfilenew
        } else {
$hashfileout = $hashfile
        }

Write-Output "Writing file hashes to: $hashfileout"

function MD5HashEfi() {
$md5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider

$EfiFilePath = "W:\EFI\Microsoft\Boot\bootmgfww.efi"
$hash = [System.BitConverter]::ToString($md5.ComputeHash([System.IO.File]::ReadAllBytes($EfiFilePath))).Replace("-","")
Write-Output "$EfiFilePath MD%: $hash"
Out-File -FilePath $hashfileout -InputObject $hash

$EfiFilePath = "W:\EFI\Microsoft\Boot\bootmgfw.efi"
$hash = [System.BitConverter]::ToString($md5.ComputeHash([System.IO.File]::ReadAllBytes($EfiFilePath))).Replace("-","")

Write-Output "$EfiFilePath MD%: $hash"
Out-File -FilePath $hashfileout -InputObject $hash -Append


$EfiFilePath = "$GrubForMsEfiLoc"
$hash = [System.BitConverter]::ToString($md5.ComputeHash([System.IO.File]::ReadAllBytes($EfiFilePath))).Replace("-","")

Write-Output "$EfiFilePath MD%: $hash"
Out-File -FilePath $hashfileout -InputObject $hash -Append
}
MD5HashEfi

function CompareHashFiles() {
if((Get-FileHash $hashfile).hash  -ne (Get-FileHash $hashfilenew).hash) {
write-output "EFI files are different replacing changed EFI files"

	write-output "Locate grub*.efi and path:"
	$GrubEfiFileLoc = Get-ChildItem –Path W:\EFI -include grubx64.efi*,grubia32.efi* -Force -Recurse |
		? FullName -notLike 'W:\EFI\Microsoft\Boot\grubx64.efi*' |
			? FullName -notLike 'W:\EFI\Microsoft\Boot\grubia32.efi*' |
				Get-ChildItem -File -Force |
				select-object -Expand FullName
#	$GrubEfiFileLoc 

	$GrubPwd = Split-Path -Path "$GrubEfiFileLoc" -Parent
	write-output "GRUB location: $GrubPwd"


	if (Test-Path "$GrubPwd\grubia32.efi*") {
	$GrubForMsEfiLoc = "W:\EFI\Microsoft\Boot\grubia32.efi"
	write-output "GRUB EFI is 32bit using: $GrubForMsEfiLoc"
	} else {
	$GrubForMsEfiLoc = "W:\EFI\Microsoft\Boot\grubx64.efi"
	write-output "GRUB EFI is 64bit using: $GrubForMsEfiLoc"
	}

	if((Get-FileHash $GrubEfiFileLoc).hash  -ne (Get-FileHash $GrubForMsEfiLoc).hash) {
	Write-Output "$GrubEfiFileLoc is not the same as $GrubForMsEfiLoc"
	cp $GrubPwd W:\EFI\Microsoft\Boot\
	cp $GrubEfiFileLoc W:\EFI\Microsoft\Boot\bootmgfw.efi
	} else { 
	Write-Output "$GrubEfiFileLoc is and $GrubForMsEfiLoc are the same file" 
    }

	write-output "Locate grub*.efi and path:"

	$GrubEfiFileLoc = Get-ChildItem –Path W:\EFI -include grubx64.efi*,grubia32.efi* -Force -Recurse |
    ? FullName -notLike 'W:\EFI\Microsoft\Boot\grubx64.efi*' |
        ? FullName -notLike 'W:\EFI\Microsoft\Boot\grubia32.efi*' |
        Get-ChildItem -File -Force |
            select-object -Expand FullName
	$GrubEfiFileLoc 

	$GrubPwd = Split-Path -Path "$GrubEfiFileLoc" -Parent
	write-output "GRUB location: $GrubPwd"


	if (Test-Path "$GrubPwd\grubia32.efi*") {
	$GrubForMsEfiLoc = "W:\EFI\Microsoft\Boot\grubia32.efi"
	write-output "GRUB EFI is 32bit using: $GrubForMsEfiLoc"
	} else {
	$GrubForMsEfiLoc = "W:\EFI\Microsoft\Boot\grubx64.efi"
	write-output "GRUB EFI is 64bit using: $GrubForMsEfiLoc"
	}

	if((Get-FileHash $GrubEfiFileLoc).hash  -ne (Get-FileHash $GrubForMsEfiLoc).hash) {
	Write-Output "$GrubEfiFileLoc is not the same as $GrubForMsEfiLoc"
	cp $GrubPwd W:\EFI\Microsoft\Boot\
	cp $GrubEfiFileLoc W:\EFI\Microsoft\Boot\bootmgfw.efi
	} else { 
	Write-Output "$GrubEfiFileLoc is and $GrubForMsEfiLoc are the same file, no need to update GRUB" 
	}

	cp $hashfileout $hashfile

	} else {
	Write-output  "EFI files are the same"
	}

}
CompareHashFiles


Write-Output "All should be well"
pause
