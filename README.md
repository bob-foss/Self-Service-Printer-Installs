# Self-Service Printer Install Script

This Powershell script eliminates printer add requests! It pulls the IP address of the PC running it, and then queries print servers for all printers in the same building as the user (by matching IP subnets). It then pulls a list of those printers, and presents a user with a list of printers they can install. 

## Setup
Change the names of the printer servers in line 2.  
Lines 64 and 65 can be toggled based on if you'd like the printers to be installed through explorer.exe or through Add-Printer. 

## How it works
First, it grabs the hostnames/IP addresses of the print servers on your network and assigns it to $Servers.  

Then it tests each network interface, grades it based off of performance, chooses the best, gets the IP address for that network interface, and assigns it to $userIP. It then writes that IP to the console as a debugging line. 

Then using some string slicing, it grabs the first 3 octets of an IP address and stores it in a variable called $subnet, then writes it to the console for debugging purposes. 

It then runs a loop and stores it in a variable called $Report. 
- For each server in the defined list of print servers, it runs Get-Printer, which lists all of the printers it has installed. 
- From there, that list is filtered using Where-Object to match $subnet to the printer's PortName. * is used to match all printer IP values, as long as they include $subnet's value at the start. 
- From there, Select-Object filters it further to only includes the following values in its output: Server, ShareName, and PortName

It then prints $Report to the console as a list with a number next to it. Each line of $Report is fed into ForEach-Object, which begins incrementing a variable called $i and processing (with -Process) further work to each line. It then uses Write-Host to add $i to the start of each line, creates another variable called Index (that has the same value as $i) then the share name, then raises $i by 1 with $i++. The result is a list of printers, their server, and their ip addresses. 

Next it asks the user to choose a printer, and save that to $selection, and offers a little useful hint for people who might not know the names of their printers.  A new variable is made from that called $chosenprinter that's the result of querying $Report and finding the printer where the Index variable matches the $selection variable. 

From there it prepares the variables for the proper command to install the printer, either through Add-Printer or through explorer.exe. Lines 64 and 65 can be toggled based on preference. 

After that, it wishes the user a nice day and closes out after 5 seconds. 
