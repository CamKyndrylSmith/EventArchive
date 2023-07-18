># tpa_log_windows
>

>## Synopsis
>This repository contains playbooks and scripts to setup a custom Windows Event log archive solution. The playbooks create a secure encrypted password file, a schedule that runs >daily to copy archive files to a central file system, and a script to maintan the archive files. 
---

>## Playbook Overview and Execution

>### Setup  
>**CreateEncryptedPasswordFile.yml** This playbook is the setups up the encrypted password file. password string to create the file for the solution in the *C:\Kyndryl* folder, for >future reference. 
>#### Variables
>| Variable | Default  | Comment |
>| --- | ---  | --- |
>| storage_password | None | **Mandatory** This password string is required to create the creditals for running this upload process.  

>### Upload schedule creation 
>**CreateTask.yml** This playbook will create a windows task schedule that will run the *UploadArchive.ps1* PowerShell script. The Schedule Task time will be a random time between >11pm and midnight that will run daily. In the setup step the creation of the encrypted *Credential.enc* will be used as the credentials of the server user that will run the Schedule >task.  
>#### Variables
>| Variable | Default  | Comment |
>| --- | ---  | --- |
>|  

>### Execution Report
>**ExecutionReport.yml** This playbook will check the create schedule task on all hosts and produce an execution report email.
>#### Variables
>| Variable | Default  | Comment |
>| --- | ---  | --- |
>|  
>### 180 day clean up
>**RemoveFiles.ps1** This is a PowerShell script which removes any archive files that have a creation date greater than 180 days. The script will produce a deletion report.

>#### Variables
>| Variable | Default  | Comment |
>| --- | ---  | --- |
>| $StorageUser | None | **Mandatory**  User that has accesss to archive files |
>| $Days | 180 | Define amount of days |
>| $Targetfolder | C:\Logs | Define folder where archive event logs files are located 
>| $Extension | *.evntx | Define extension of file to be removed 
>| $LogDir | C:\Logs | Log file location   

>### Clean Project
>**ProjectClean.yml** This ansible playbook can be run to clean up the related Scheduled Tasks and files, that are created for this project.

>### Details on encrypting file using user and machine keys
https://stackoverflow.com/questions/23699500/convertto-securestring-gives-different-experience-on-different-servers
