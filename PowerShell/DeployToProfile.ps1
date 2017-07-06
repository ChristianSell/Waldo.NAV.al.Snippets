$SnippetFileName = 'al.json'

$ProjectFileName = get-item (Join-Path '.' "$SnippetFileName") -ErrorAction SilentlyContinue
if (!($ProjectFileName)){
    $ProjectFileName = join-path $PSScriptroot "..\$SnippetFileName"
}
$ProfileFileName = join-path $env:USERPROFILE "AppData\Roaming\Code\User\snippets\$SnippetFileName"

Copy-Item -Path $ProjectFileName -Destination $ProfileFileName
