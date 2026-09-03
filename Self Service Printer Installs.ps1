# Enter the hostnames/IP addresses of your print servers here. 
$Servers = @("anpsw22", "192.168.189.39", "192.168.189.19")

Write-Host "Welcome! This tool can add printers to your PC for you. "

# Test each network interface, grade it based off of performance, choose the best, get the IP address for that network interface, assign it to $userIP
$bestRoute = Get-NetRoute -DestinationPrefix '0.0.0.0/0' -ErrorAction SilentlyContinue |
    Sort-Object -Property RouteMetric | Select-Object -First 1
$userIP = (Get-NetIPAddress -InterfaceIndex $bestRoute.InterfaceIndex -AddressFamily IPv4).IPAddress

# Little debug comment
Write-host "Your IP is $userIP."

# Get the first 3 octets, assign it to $subnet
$subnet = ($userIP -split '\.')[0..2] -join '.'
# Little debug comment
Write-Host "Detected subnet: $subnet.x"


Write-Host "Pulling printers from your site..."

# Get printer info from each of the print servers in $Servers, then assign it to $Report.
# I should get better documentation for this section.
$Report = foreach ($Server in $Servers) {
    Get-Printer -ComputerName $Server |
        Where-Object { $_.PortName -like "$subnet*" } |
        Select-Object @{Name="Server";Expression={$Server}},
                      ShareName,
                      PortName}


# Helpful little error line. 
if (!$Report) {
    Write-Host "No printers found on your subnet $subnet.x" -ForegroundColor Red
    Start-Sleep 1
    exit
}

# Print $Report to the console as a list with a number next to it. 
# I should get better documentation for this section.
Write-Host "`nAvailable Printers:"
$Report | ForEach-Object -Begin {$i=1} -Process {
    Write-Host "$i) $($_.ShareName)  "
    $_ | Add-Member -NotePropertyName Index -NotePropertyValue $i
    $i++
}

# Ask user to choose a printer, and save that input to $selection
Write-Host "`nEnter the number of the printer you want to install."
$selection = Read-Host "`nYou can get the printer name from a colleague who can print. "


# I should get better documentation for this section.
$chosenPrinter = $Report | Where-Object { $_.Index -eq [int]$selection }

# Helpful little error line. 
if (!$chosenPrinter) {
    Write-Host "Invalid selection. Exiting." -ForegroundColor Red
    exit
}

$printerFullPath = "\\$($chosenPrinter.Server)\$($chosenPrinter.ShareName)"

# Helpful little debug line. 
Write-Host "`nInstalling printer $printerFullPath..."

# 2 install methods. Explorer.exe tends to work better for me, but this line can be toggled off and you can use Add-Printer instead. 
#Add-Printer -ConnectionName $printerFullPath
explorer.exe $printerfullpath

# Close out the script on user's PC. 
Write-Host "For any other problems, please call the help desk at x3057."
Write-Host "Have a nice day!"
Start-Sleep 5
exit