#-------------------------------------------------------------------------------------------------------------"
#   RemoveFiles
#
#  This powershell removes files from a defined folder for the defined number of days. And creates a report.
#
# Cameron Smith 12-07-2023  Initial version 
#-------------------------------------------------------------------------------------------------------------"
write-host "Starting" 

#----- Define parameters -----#
$Days = "180"                                       # define amount of days 
$Now = Get-Date                                     # Current Date Time
$DisplayNow = Get-Date -format "yyyyMMdd_HHmmss"    # Date time format yyymmdd_HHmmss
$Lastwrite = $Now.AddDays(-$Days)                   # Date and time minus amout of days  
$Targetfolder = "C:\Logs"                           # define folder where files are located 
$Extension = "*.txt"                                # define extension 
$LogFile = "C:\Logs\RemoveFile_$DisplayNow.log"     # Log file for this run  

write-host "Date: $Now"
write-host "Create date: $Lastwrite  (-$Days days)"

#Create the log file
#Check if file exists
if (Test-Path $LogFile) {
    Write-host "File '$LogFile' already exists!" -f Yellow
}
Else {
    #Create a new file
    New-Item -Path $LogFile -ItemType "File"
    Write-host "New File '$LogFile' Created!" -f Green
}

Add-Content -Path $LogFile -Value "`n`t`t --- Event Log archive delete (-$Days days) --- `n`t`t`tToday:  $DisplayNow `n _____________________________________________________________________"

#----- Get files based on lastwrite filter and specified folder ---#
$Files = Get-Childitem -Path $Targetfolder -include $Extension -Recurse | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $Lastwrite}
write-host "Number of file found for deletion:" $Files.Count 

#Check if files were found to be removed 
if ($Files.Count -gt 0)
{         
    foreach ($File in $Files)
    {
         
        if ($null -ne $File)
        {
            write-host "Deleted File $File " -backgroundcolor "DarkRed"
            $crDate = $File.CreationTime
            Add-Content -Path $LogFile -Value "  Deleted File: $File `t Creation date: $crDate "
            Remove-item $File.Fullname | out-null
        }
    }
}else {
    write-host "No files found over $Days days old." -backgroundcolor "Green"
    Add-Content -Path $LogFile -Value "`n`t No files found over $Days days old."
}