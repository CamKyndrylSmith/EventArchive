#-------------------------------------------------------------------------------------------------------------"
#   RemoveFiles
#
#  This powershell removes files from a defined folder for the defined number of days. And creates a report.
#
# Cameron Smith 12-07-2023  Initial version 
#-------------------------------------------------------------------------------------------------------------"
param (
        #----- Define parameters -----#
        [String]$Days = "180",                                                      # Define amount of days 
        [String]$Targetfolder = "\\tdlbkpprod0201.melb.ad\wineventlogs_nonprod\",   # Define folder where archive event logs files are located 
        [String]$Extension = "archive*.evtx",                                       # Define extension of file to be removed 
        [String]$LogDir = "Logs",                                                   # Log file location   
        [String]$StorageUser = "windowslogging"                                     # User that has accesss to archive files 
)

$Now = Get-Date                                                                     # Current Date Time
$DisplayNow = Get-Date -format "yyyyMMdd_HHmmss"                                    # Date time format yyymmdd_HHmmss
$Lastwrite = $Now.AddDays(-$Days)                                                   # Date and time minus amout of days  
$PasswordFile = "C:\Kyndryl\Credential.enc"                                         # Encrpted password file


# Read the encrypted password from the text file
$securePassword = $(Get-Content -Path $PasswordFile | ConvertTo-SecureString)
            
# Create a PSCredential object with the network credentials
$credential = New-Object System.Management.Automation.PSCredential($StorageUser, $securePassword)

# Go through drives and check if it is being used
foreach ($drvletter in "ABDEFGHIJKLMNOPQRSTUVWXYZ".ToCharArray()) {
  # Check if the drive is being used. If yes go to next letter
  if(Get-Volume -FilePath $drvletter":\")
    { continue }
  
  # Temporarily map drive
  New-PSDrive -Name $drvletter -PSProvider FileSystem -Root $Targetfolder -Credential $credential
    
  #Build Log file path
  $LogFile = "{0}:\{1}\RemoveFile_{2}.log" -f $drvletter,$LogDir,$DisplayNow  
   
  # Create the log file
  #   + Check if file exists
  if (Test-Path $LogFile) {
      Write-host "File '$LogFile' already exists!" -f Yellow
  }
  else {
      #Create a new file
      New-Item -Path $LogFile -ItemType "File"
      Write-host "New File '$LogFile' Created!" -f Green
  }
  
  # Add header to the log file
  Add-Content -Path $LogFile -Value "`n`t`t --- Event Log archive delete (-$Days days) --- `n`t`t`tToday:  $DisplayNow `n _____________________________________________________________________"
  
  # Get files based on lastwrite filter and specified folder 
  $Files = Get-Childitem -Path $drvletter":\TestEvent" -include $Extension -Recurse | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $Lastwrite}
  
  #Check if files were found to be removed 
  if ($Files.Count -gt 0)
    {         
        foreach ($File in $Files)
        {
          if ($null -ne $File)
            {
              $crDate = $File.CreationTime
              Add-Content -Path $LogFile -Value "  Deleted File: $File `t Creation date: $crDate "
              Remove-item $File.Fullname | out-null
            }
        }
    }else {
      Add-Content -Path $LogFile -Value "`n`t No files found over $Days days old."
    }

  # Remove drive
  Get-PSDrive $drvletter | Remove-PSDrive -Force -Verbose

  # Exit with success return code
  Exit 0
}