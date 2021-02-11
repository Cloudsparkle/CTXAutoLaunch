param ($PublishedApp)

if ($PublishedApp -eq $null)
{
    Write-Host "No Published Resource given as argument... Exiting"
    exit 0
}  

#########################################################################
#                        Add shared_assemblies                          #
#########################################################################
$currentDir = [System.AppDomain]::CurrentDomain.BaseDirectory.TrimEnd('\')
if ($currentDir -eq $PSHOME.TrimEnd('\'))
	{
		$currentDir = $PSScriptRoot
	}

[System.Reflection.Assembly]::LoadWithPartialName('presentationframework') | out-null
# Mahapps Library
[System.Reflection.Assembly]::LoadFrom($currentdir + '\assembly\MahApps.Metro.dll') | Out-Null      
[System.Reflection.Assembly]::LoadFrom($currentdir + '\assembly\System.Windows.Interactivity.dll') | Out-Null

#########################################################################
#                            Splash Screen                              #
#########################################################################
function close-SplashScreen (){
    $hash.window.Dispatcher.Invoke("Normal",[action]{ $hash.window.close() })
    $Pwshell.EndInvoke($handle) | Out-Null
    $runspace.Close() | Out-Null
    
}

function Start-SplashScreen{
    $Pwshell.Runspace = $runspace
    $script:handle = $Pwshell.BeginInvoke() 
}
    $hash = [hashtable]::Synchronized(@{})
    $runspace = [runspacefactory]::CreateRunspace()
    $runspace.ApartmentState = "STA"
    $Runspace.ThreadOptions = "ReuseThread"
    $runspace.Open()
    $runspace.SessionStateProxy.SetVariable("hash",$hash) 
    $Pwshell = [PowerShell]::Create()

    $Pwshell.AddScript({
    $xml = [xml]@"
     <Window
	xmlns:Controls="clr-namespace:MahApps.Metro.Controls;assembly=MahApps.Metro"
	xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
	xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
	x:Name="WindowSplash" Title="SplashScreen" WindowStyle="None" WindowStartupLocation="CenterScreen"
	Background="Black" ShowInTaskbar ="true" 
	Width="600" Height="350" ResizeMode = "NoResize" >
	
	<Grid>
		<Grid.RowDefinitions>
            <RowDefinition Height="70"/>
            <RowDefinition/>
        </Grid.RowDefinitions>
		
		<Grid Grid.Row="0" x:Name="Header" >	
			<StackPanel Orientation="Horizontal" HorizontalAlignment="Left" VerticalAlignment="Stretch" Margin="20,10,0,0">       
				<Label Content="CTXAutoLaunch" Margin="0,0,0,0" Foreground="White" Height="50"  FontSize="30"/>
			</StackPanel> 
		</Grid>
        <Grid Grid.Row="1" >
		 	<StackPanel Orientation="Vertical" HorizontalAlignment="Center" VerticalAlignment="Center" Margin="5,5,5,5">
				<Label x:Name = "LoadingLabel"  Foreground="White" HorizontalAlignment="Center" VerticalAlignment="Center" FontSize="24" Margin = "0,0,0,0"/>
				<Controls:MetroProgressBar IsIndeterminate="True" Foreground="White" HorizontalAlignment="Center" Width="350" Height="20"/>
			</StackPanel>	
        </Grid>
	</Grid>
		
</Window> 
"@
         
    $reader = New-Object System.Xml.XmlNodeReader $xml
    $hash.window = [Windows.Markup.XamlReader]::Load($reader)
    $hash.LoadingLabel = $hash.window.FindName("LoadingLabel")
    $hash.LoadingLabel.Content= "Loading"  
    $hash.window.ShowDialog()
    
     
    
}) | Out-Null

#we open our splash-screen
Start-SplashScreen
 

#########################################################################
#                       Main Pannel Event                               #
#########################################################################

$keys = Get-ChildItem -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall|Get-ItemProperty

foreach ($key in $keys)
{    
    if (($key.Displayname -eq $PublishedApp) -or ($key.CTX_Displayname -eq $PublishedApp))
    {
        start-process -filepath $key.shortcuttarget -argumentlist "-showAppPicker"
        Sleep 30
        close-SplashScreen
        start-Process -FilePath $key.shortcuttarget -ArgumentList $key.launchstring
        exit 0
    }
       
}
close-SplashScreen | Out-Null
exit 0

