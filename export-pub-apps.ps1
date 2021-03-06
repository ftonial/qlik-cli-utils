<#
MIT License

Copyright (c) 2018 Clever dos Anjos

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

#>
#
# Dump published apps
# a folder for each stream
# ***
# WARNING, all unpublished sheets will be published to be exported
# ***
# 

$folder = "c:\dump"

Connect-Qlik|Out-Null ## check https://github.com/ahaydon/Qlik-Cli for details

foreach($qvf in Get-QlikApp -filter "Published eq true and stream.name eq 'Everyone'") {
    $unpublishedSheets = Get-QlikObject -filter "app.id eq $($qvf.id) and published eq false and objectType eq 'sheet'"
    foreach($s in $unpublishedSheets) { 
        Publish-QlikObject -id $s.id
        Update-QlikObject -Approved $true -id $s.id
    }

    $unapprovedSheets = Get-QlikObject -filter "app.id eq $($qvf.id) and approved eq false and objectType eq 'sheet'"
    foreach($s in $unapprovedSheets) { 
        Update-QlikObject -Approved $true -id $s.id
    }
    $streamfolder = $qvf.stream.name
    New-Item -ItemType Directory -Force -Path "$folder\$streamfolder"
    Export-QlikApp -id $qvf.id -filename "$($folder)\$($streamfolder)\$($qvf.name).qvf" #dumps the qvf
    foreach($s in $unapprovedSheets) { 
        Update-QlikObject -Approved $false -id $s.id 
    }
    foreach($s in $unpublishedSheets) { 
        Update-QlikObject -Approved $false -id $s.id 
        Unpublish-QlikObject -id $s.id
        
    }
}


## End of file