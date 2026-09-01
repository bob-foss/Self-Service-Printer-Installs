# Self-Service-Printer-Installs
This Powershell script eliminates printer add requests! It pulls the IP address of the PC running it, and then queries print servers for all printers in the same building as the user (by matching IP subnets). It then pulls a list of those printers, and presents a user with a list of printers they can install. 
