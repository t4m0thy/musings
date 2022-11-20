#Super dirty script to check your onedrive for any files with " - Copy" appended on the end, does a quick hash of both files and if the same, keeps the " - Copy" file as that was the one originally on your machine.


$path = $env:OneDrive

$copyList = (Get-ChildItem -path $path -recurse | where-object {$_.basename -like "* - Copy" })
$fileList = (Get-ChildItem -path $path -recurse | where-object {$_.basename -notlike "* - Copy" })

$errorList = @()

$fileTotal = $copyList.count
$filecount = 0

foreach ($copy in $copyList) {

    $fileCount += 1

    Remove-Variable -Name file -ErrorAction SilentlyContinue
    
    $compare = "- Copy"

    $file = $fileList | where-object { ("$($_.basename) $compare" -eq $copy.basename) -and ($_.DirectoryName -eq $copy.DirectoryName) -and ($_.extension -eq $copy.extension) } -ErrorAction SilentlyContinue

    if ($file) {

        Remove-Variable -Name copyHash -ErrorAction SilentlyContinue
        Remove-Variable -Name fileHash -ErrorAction SilentlyContinue

        $copyHash = Get-FileHash $copy.FullName
        $fileHash = Get-FileHash $file.FullName

        if ($copyHash.hash -eq $fileHash.hash) {
            Write-Progress -Activity "Current: $fileCount / $fileTotal  $($file.fullname) LastError: $($errorlist[($errorlist.count - 1)])"
            $file | Remove-Item -Confirm:$false
            rename-item -Path $copyHash.path -NewName $file.name
        } else {
            Write-Error "$($file.fullname) error"
            $errorList += $file.fullname
        }
    }
}

Write-Progress -Completed -Activity "None"
