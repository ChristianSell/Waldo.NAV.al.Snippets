#Open snippets from the al extension
$ALExtension = Get-ChildItem (Join-Path $env:USERPROFILE '.vscode\extensions\') | where Name -Like 'Microsoft.al*'

psedit (get-item (join-path $ALExtension.FullName 'Snippets\al.json'))

psedit (get-item (join-path $ALExtension.FullName 'Snippets\page.json'))

