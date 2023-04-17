Write-Output "Workaround read only NVRAM or in my case a hacked BIOS with hardcoded defaults and an early version EFI." 
pause

$msefi = 'W:\EFI\Microsoft\Boot\bootmgfw.efi'

if (-not (Test-Path $msefi)) {
Write-Output "Mounting EFI to W:"
mountvol w: /S
}

$checkforstring = (Get-ChildItem -Path $msefi| Select-Object -First 1).fullname
if ($checkforstring) {
    $search = (Get-Content $checkforstring | Select-String -Pattern 'Microsoft Corporation').Matches.Success
    if($search){
        Write-output "$msefi contians the string Microsoft Corporation proceeding."
        cp  $msefi W:\EFI\Microsoft\Boot\bootmgfw.efi.bak
        cp  $msefi W:\EFI\Microsoft\Boot\bootmgfww.efi
    } else {
        Write-output "$msefi does not contians the string 'Microsoft Corporation'."
        $ask = Read-Host -Prompt "Continue to check/update GRUB?[y/n]"
         if ( $ask -eq 'n' ) {
			pause
			break
         }
    }
} else {
    "No file: $msefi"
}

write-output "Locate signed or unsigned Secure Boot shim*.efi* and grub*.efi* files and path:"
$GrubEfiSecFileLoc = Get-ChildItem –Path W:\EFI -include shim*.efi -Force -Recurse |
		? FullName -notLike 'W:\EFI\Microsoft\Boot\shim*.efi*' |
				Get-ChildItem -File -Force |
				select-object -Expand FullName
#	$GrubEfiSecFileLoc 

	$GrubPwd = Split-Path -Path "$GrubEfiSecFileLoc" -Parent
	
	if (Test-Path "$GrubPwd\shim*.efi") {
        $ask = Read-Host -Prompt "Found unsigned Secure Boot GRUB .efi, use this file?[y/n]"
		  if ( $ask -eq 'y' ) {
					$GrubForMsEfiLoc = Split-Path -Path $GrubPwd\shim*.efi
					write-output "Using unsigned GRUB EFI: $GrubForMsEfiLoc"
			}
	}
				
	if (Test-Path "$GrubPwd\shim*.efi.*") { 
		$ask = Read-Host -Prompt "Found Microsoft signed Secure Boot GRUB .efi, use this file?[y/n]"
			if ( $ask -eq 'y' ) {
				$GrubForMsEfiLoc = Split-Path -Path $GrubPwd\shim*.efi*
				write-output "Wsing signed GRUB EFI : $GrubForMsEfiLoc"
			}
	}

$GrubEfiFileLoc = Get-ChildItem –Path W:\EFI -include grub*.efi -Force -Recurse |
		? FullName -notLike 'W:\EFI\Microsoft\Boot\grub*.efi*' |
				Get-ChildItem -File -Force |
				select-object -Expand FullName
#	$GrubEfiFileLoc

	$GrubPwd = Split-Path -Path "$GrubEfiFileLoc" -Parent


	if (Test-Path "$GrubPwd\grubi*.efi") {
		$ask = Read-Host -Prompt "Found unsigned secure boot GRUB .efi, use this file?[y/n]"
		if ( $ask -eq 'y' ) {
			$GrubForMsEfiLoc = Split-Path -Path $GrubPwd\grubi*.efi
			write-output "Using unsigned GRUB EFI: $GrubForMsEfiLoc"
		}
	}

	if (Test-Path "$GrubPwd\grubi*.efi*") {
		$ask = Read-Host -Prompt "Found your Linux distributions signed GRUB .efi, use this file?[y/n]"
			if ( $ask -eq 'y' ) {
				$GrubForMsEfiLoc = Split-Path -Path $GrubPwd\grubi*.efi*
				write-output "Using signed GRUB EFI: $GrubForMsEfiLoc"
			}
	}

	if (-not (Test-Path $GrubForMsEfiLoc) {
		Write-Output "No GRUB EFI file found or selected. Aborting"
		pause
		break
	}
	write-output "GRUB location: $GrubPwd"

Write-Output "MD5 compare W:\EFI\*.efi" 

$hashfile = "W:\hash.output.txt"
$hashfilenew = "W:\hash.output.new.txt"

if (-not (Test-Path -Path $hashfilenew)) {
$hashfileout = $hashfile
$hashfilenew = $null
        } else {
$hashfileout = $hashfilenew
        }

Write-Output "Writing file hashes to: $hashfileout"

function MD5HashEfi() {
$md5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider

	$EfiFilePath = "$msefi"
	$hash = [System.BitConverter]::ToString($md5.ComputeHash([System.IO.File]::ReadAllBytes($EfiFilePath))).Replace("-","")
	Write-Output "$EfiFilePath MD5: $hash"
	Out-File -FilePath $hashfileout -InputObject $hash 

	$EfiFilePath = "W:\EFI\Microsoft\Boot\bootmgfww.efi"
	$hash = [System.BitConverter]::ToString($md5.ComputeHash([System.IO.File]::ReadAllBytes($EfiFilePath))).Replace("-","")
	Write-Output "$EfiFilePath MD5: $hash"
	Out-File -FilePath $hashfileout -InputObject $hash -Append

	if (Test-Path $GrubForMsEfiLoc) {
	$EfiFilePath = "$GrubForMsEfiLoc"
	$hash = [System.BitConverter]::ToString($md5.ComputeHash([System.IO.File]::ReadAllBytes($EfiFilePath))).Replace("-","")
	Write-Output "$EfiFilePath MD5: $hash"
	Out-File -FilePath $hashfileout -InputObject $hash -Append
	}

}
MD5HashEfi

function CompareHashFiles() {
if((Get-FileHash $hashfile).hash  -ne (Get-FileHash $hashfilenew).hash) {
write-output "EFI files are different replacing changed EFI files"

	if((Get-FileHash $GrubEfiFileLoc).hash  -ne (Get-FileHash $GrubForMsEfiLoc).hash) {
	Write-Output "$GrubEfiFileLoc is not equal to: $GrubForMsEfiLoc"
	cp  $GrubPwd W:\EFI\Microsoft\Boot\
	} else { 
	Write-Output "$GrubEfiFileLoc  is equal to: $GrubForMsEfiLoc" 
    }

	if((Get-FileHash $msefi).hash  -ne (Get-FileHash $GrubForMsEfiLoc).hash) {
	Write-Output "$GrubEfiFileLoc is not equal to: $msefi"
	cp  $GrubEfiFileLoc $msefi
	} else { 
	Write-Output "$GrubEfiFileLoc is equal to: $msefi" 
    }

 cp $hashfileout $hashfile

	} else {
	Write-output  "EFI files are the same"
	}

}
CompareHashFiles


Write-Output "All should be well"
pause
