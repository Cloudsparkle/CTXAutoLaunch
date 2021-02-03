param ($PublishedApp)

$keys = Get-ChildItem -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall|Get-ItemProperty

foreach ($key in $keys)
{    
    if (($key.Displayname -eq $PublishedApp) -or ($key.CTX_Displayname -eq $PublishedApp))
    {
        start-process -filepath $key.shortcuttarget -argumentlist "-showAppPicker"
        Sleep 15
        Start-Process -FilePath $key.shortcuttarget -ArgumentList $key.launchstring
    }
     
    if ($key.CTX_Displayname -eq $PublishedApp)
    {
        start-process -filepath $key.shortcuttarget -argumentlist "-showAppPicker"
        Sleep 15
        Start-Process -FilePath $key.shortcuttarget -ArgumentList $key.launchstring
    }
}