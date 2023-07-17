#-------------------------------------------------------------------------------------------------------------"
#   Upload Archive
#
#  This powershell copies archive event log files to file system for storage. 
#         0   - Sucessful
#         1   - Error
#         10  - No Drive letters avaible to map
#
#-------------------------------------------------------------------------------------------------------------"
param(
  $SourcePath,
  $Destination,
  $PasswordFile,
  $StorageUser
)

try {
  # Read the encrypted password from the text file
  $securePassword = $(Get-Content -Path $PasswordFile | ConvertTo-SecureString)
            
  # Create a PSCredential object with the network credentials
  $credential = New-Object System.Management.Automation.PSCredential($StorageUser, $securePassword)
  
  # Go through drives and check if it is being used
  Foreach ($drvletter in "ABDEFGHIJKLMNOPQRSTUVWXYZ".ToCharArray()) {
    # Check if the drive is being used. If yes go to next letter
    if(Get-Volume -FilePath $drvletter":\"){ continue }
    
    # Temporarily map drive
    New-PSDrive -Name $drvletter -PSProvider FileSystem -Root $Destination -Credential $credential
    
    # Get all files in folder than end with .evtv
    Get-ChildItem -Path $SourcePath -Filter "*.evtx" | ForEach-Object {
      # Create folder of server name, if it doesn't exist.
      If(!(test-path -PathType container $drvletter":\$($env:computername)\")) {
        New-Item -ItemType Directory -Path $drvletter":\$($env:computername)\"
      }
      
      # Copy file to remote folder
      Move-Item -Path $_.FullName -Destination "A:\$($env:computername)\$($_.Name)"
    }
  
    # Remove drive
    Get-PSDrive $drvletter | Remove-PSDrive -Force -Verbose
  
    # Exit with success return code
    Exit 0
  }
  
  # No available drives
  Exit 10
}
catch{ Exit 1 }
