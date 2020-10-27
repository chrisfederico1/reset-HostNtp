function reset-hostntp () 
{
    <#
	.SYNOPSIS
    Replaces all NTP servers on Hosts
    
	.DESCRIPTION
    This function will remove NTP servers and replace them with new NTP servers.
    
	.Example
    reset-hostntp -Cluster clustername
    reset-hostntp -VMHost hostname

	    
	.Notes
	NAME: reset-hostntp.ps1
    AUTHOR: Chris Federico  
	LASTEDIT: 10/27/2020
	VERSION: 1.0
	KEYWORDS: VMware, vSphere, ESXi, NTP

#>

# Parameters
[CmdletBinding()]
param
(
    [Parameter(Mandatory=$false)]
    [string]$Cluster,

    [Parameter(Mandatory=$false)]
    [string]$VMHost
)

Begin {


    # Clear Screen
    Clear-Host

    # Start the logger
    Start-Transcript -path .\reset-hostntp.txt -Force

    # Get NTP Server List
    $InputNTP1 = Read-Host "First NTP Server:" 
    $InputNTP2 = Read-Host "Second NTP Server:" 
    $InputNTP3 = Read-Host "Third NTP Server:" 
    $InputNTP4 = Read-Host "Fourth NTP Server:"
    
    
}

Process {

    #NTP Servers to be changed
    $ntp1 = $InputNTP1 
    $ntp2 = $InputNTP2 
    $ntp3 = $InputNTP3 
    $ntp4 = $InputNTP4

    If ($Cluster)
    {
        #Select Cluster to change NTP Settings 
        $ClusterName = Get-Cluster $Cluster

        #Grabbing VMHosts for desired Cluster 
        $allVMhost = $ClusterName | Get-VMHost | Sort-Object Name
        
        #Reseting NTP servers one by one 

        foreach ($vmhostName in $allVMhost)
                 { 
                 #Remove existing NTP servers 
                 Write-Host "INFO: Removing all NTP Servers from $vmhostName" 
                 $allNTPList = Get-VMHostNtpServer -VMHost $vmhostName 
                 Remove-VMHostNtpServer -VMHost $vmhostName -NtpServer $allNTPList -Confirm:$false | out-null 
                 Write-Host "INFO: All NTP Servers from $vmhostName have been removed" 
                 Write-Host ""

                 #Setting NTP servers 
                 Write-Host "INFO: Adding NTP servers to $vmhostName"
                 Add-VmHostNtpServer -NtpServer $ntp1,$ntp2,$ntp3,$ntp4 -VMHost $vmhostName -Confirm:$false | out-null
                 Write-Host "INFO: The following NTP servers have been added to $vmhostName : $ntp1, $ntp2, $ntp3, $ntp4" 
                 Write-Host ""

                 #Checking NTP Service on the ESXi host 
                 $ntp = Get-VMHostService -vmhost $vmhostName| where-object {$_.Key -eq 'ntpd'} 
                 Set-VMHostService $ntp -Policy on | out-null

                 if ($ntp.Running ){ 
                    Restart-VMHostService $ntp -confirm:$false 
                    Write-Host "INFO: $ntp Service on $vmhostName was On and was restarted"
                    }
                    Else{ 
                        Start-VMHostService $ntp -confirm:$false 
                        Write-Host "INFO: $ntp Service on $vmhostName was Off and has been started"
                    }

                 }
        }
        else {
            #Remove existing NTP servers
            Write-Host "INFO: Removing all NTP Servers from $VMHost"
            $allNTPList = Get-VMHostNtpServer -VMHost $VMHost
            Remove-VMHostNtpServer -VMHost $VMHost -NtpServer $allNTPList -Confirm:$false | out-null
            Write-Host "INFO: All NTP Servers from $VMHost have been removed" 
            Write-Host ""

            #Setting NTP servers 
            Write-Host "INFO: Adding NTP servers to $VMHost"
            Add-VmHostNtpServer -NtpServer $ntp1,$ntp2,$ntp3,$ntp4 -VMHost $VMHost -Confirm:$false | out-null
            Write-Host "INFO: The following NTP servers have been added to $VMHost : $ntp1, $ntp2, $ntp3, $ntp4" 
            Write-Host ""

            #Checking NTP Service on the ESXi host 
            $ntp = Get-VMHostService -vmhost $VMHost| where-object {$_.Key -eq 'ntpd'} 
            Set-VMHostService $ntp -Policy on | out-null

            if ($ntp.Running ){ 
                Restart-VMHostService $ntp -confirm:$false 
                Write-Host "INFO: $ntp Service on $VMHost was On and was restarted"
                }
                Else{

                    Start-VMHostService $ntp -confirm:$false 
                    Write-Host "INFO: $ntp Service on $VMHost was Off and has been started"
                }




        }

}

End {

    # Stop Logging
    Stop-Transcript
}

}