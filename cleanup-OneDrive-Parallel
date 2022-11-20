#Super dirty script to check your onedrive for any files with " - Copy" appended on the end, does a quick hash of both files and if the same, keeps the " - Copy" file as that was the one originally on your machine.
#Doesn't seem to be faster than serial after all the effort

#check local OneDrive Path, can use reg or just set a path manually
$path = $env:OneDrive
#how many files to hash/rename at once, this was taking forever in series so took the time while waiting to make it faster, YMMV, if you're using a spining disk, use a low number and watch the utilisation or disk queue length
$throttleLimit = 50

#get files with copy on the end (super irty, doesn;t account for "- Copy - Copy", but should be few and in $results.errors after the fact)
$copyList = (Get-ChildItem -path $path -recurse | where-object { $_.basename -like "* - Copy" })
#get all the files to compare against copies
$fileList = (Get-ChildItem -path $path -recurse | where-object { $_.basename -notlike "* - Copy" })

#setup hastable containing arrays so the output isn't limited
$results = @{errors=@();successes=@();debug=@()}

#start parallel foreach object
$copyList | Foreach-Object -ThrottleLimit $throttleLimit -Parallel {

    #Action that will run in Parallel. Reference the current object via $PSItem and bring in outside variables with $USING:varname
    $copy = $_
    $compare = "- Copy"

    #get file where file has the same name (with copy on the end) in the same directory with the same extension.
    $file = $using:fileList | where-object { ("$($_.basename) $compare" -eq $copy.basename) -and ($_.DirectoryName -eq $copy.DirectoryName) -and ($_.extension -eq $copy.extension) } -ErrorAction SilentlyContinue

    #as this is my first succesful use of parallel, left these in for reference, reduced $copyList to a single file name and looked at output to see if I was matching anything
    #($using:results).debug += "copy: $copy"
    #($using:results).debug += "file: $file"

    #($using:results).debug += $using:fileList

    if ($file) {

        #remove hash variables so previous iterations around the loop don't affect the current
        Remove-Variable -Name copyHash -ErrorAction SilentlyContinue
        Remove-Variable -Name fileHash -ErrorAction SilentlyContinue

        #get hashes for both files
        $copyHash = Get-FileHash $PSITEM.FullName
        $fileHash = Get-FileHash $file.FullName

        #if the hashes match, delete the downloaded non " - Copy" and rename the existing file to the old name
        if ($copyHash.hash -eq $fileHash.hash) {
            ($using:results).successes += $file.fullname
            $file | Remove-Item -Confirm:$false
            rename-item -Path $copyHash.path -NewName $file.name
        }
        else {
            #if an error is found, add the results to the error array (could go full ham and trhow custom objects in here, being lazy)
            ($using:results).errors += "file: $($file.fullname) copy: $($copy.fullname)"
        }
    }

}


