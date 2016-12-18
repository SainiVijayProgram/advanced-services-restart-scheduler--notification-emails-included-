

function Confirm-WindowsServiceExists($server_name, $service_name)
{   

   if (Get-Service -Name $service_name -Computername $server_name -ErrorAction SilentlyContinue -ErrorVariable WindowsServiceExistsError)
   {
      # Write-Host "$name Exists on $server"
	  # write-output "$(get-date) : Function:  $service_name found on $server_name " | out-file $LOG_FILE -Append -Force;  

       return $true
   }

   if ($WindowsServiceExistsError)
   {
		write-output "$(get-date) : Function:  $service_name not found on $server_name Here is the exception message $WindowsServiceExistsError[0].exception.message " | out-file $LOG_FILE -Append -Force;  

   }

   return $false
}


#----------------------------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------------------------
function Stop_Specified_Services($arr_servers, $service_name){
	
	foreach ($server_name in $arr_servers){
		
		foreach ($service_name in $arr_services){
		$no_of_try=0
		
		if(Confirm-WindowsServiceExists "$server_name" "$service_name"  ){

			#write-output "$(get-date) : $service_name was found to be installed on $server_name" | out-file $LOG_FILE -Append -Force;  
			write-output "$(get-date) : Step-A: Initial status of  $service_name on $server_name :- $($(get-service -ComputerName $server_name -Name $service_name).Status)" | out-file $LOG_FILE -Append -Force; 

			while (((Get-Service -Name $service_name -ComputerName $server_name).Status) -notlike "Stopped")	{
					$no_of_try++
						
					  # If the no of retries exceed 3, breaking the loop
					  if ( $no_of_try -gt $max_trial_allowed )
					  {
						write-output "$(get-date) : 	--Quitting Stop after $max_trial_allowed tries  " | out-file $LOG_FILE -Append -Force; 
						break
					  }

					   If (((Get-Service -Name $service_name -ComputerName $server_name).Status) -notlike "Stopped"){
					   
							If (((Get-Service -Name $service_name -ComputerName $server_name).Status) -like "StopPending"){
								
								write-output "$(get-date) : 	-Stop is Pending(In Progress). Will check again after $sleeptime seconds " | out-file $LOG_FILE -Append -Force; 
								sleep $sleeptime
							} else {
								Try{
									write-output "$(get-date) : 	-Service($service_name) is neither stopped nor the stop is pending. Hence attempting to Stop " | out-file $LOG_FILE -Append -Force; 
									(Get-Service -Name $service_name -ComputerName $server_name).Stop()
									sleep $sleeptime
								}Catch{
									write-output "$(get-date) : 	-STOP COMMAND FAILED  " | out-file $LOG_FILE -Append -Force; 
									#Send-MailMessage -From ExpensesBot@MyCompany.Com -To WinAdmin@MyCompany.Com -Subject "HR File Read Failed!" -SmtpServer EXCH01.AD.MyCompany.Com
									Break
									}
							}
						} else {
								write-output "$(get-date) : Service($service_name) was found in stopped status. Hence Getting out of loop" | out-file $LOG_FILE -Append -Force; 
								break
						}
				}
			write-output "$(get-date) : Step-B: Status of Service($service_name) before moving on :- $($(get-service -ComputerName $server_name -Name $service_name).Status)" | out-file $LOG_FILE -Append -Force; 
		
				
			} else {
			write-output "$(get-date) : $service_name :no such installed service found on $server_name" | out-file $LOG_FILE -Append -Force;  
				}
		
		}
	}
}





#----------------------------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------------------------
function Start_Specified_Services($arr_servers, $service_name){
	
	foreach ($server_name in $arr_servers){
		
		foreach ($service_name in $arr_services){
		$no_of_try=0
		
	

		if(Confirm-WindowsServiceExists "$server_name" "$service_name"  ){
			
			#write-output "$(get-date) : $service_name was found to be installed on $server_name" | out-file $LOG_FILE -Append -Force;  
			write-output "$(get-date) : Step-A: Initial status of  $service_name on $server_name :- $($(get-service -ComputerName $server_name -Name $service_name).Status)" | out-file $LOG_FILE -Append -Force; 

			If (((Get-Service -Name $service_name -ComputerName $server_name).Status) -like "Stopped"){

			
			while (((Get-Service -Name $service_name -ComputerName $server_name).Status) -notlike "Running")	{
					$no_of_try++
						
					  # If the no of retries exceed 3, breaking the loop
					  if ( $no_of_try -gt $max_trial_allowed )
					  {
						write-output "$(get-date) : 	--Quitting START after $max_trial_allowed tries  " | out-file $LOG_FILE -Append -Force; 
						break
					  }

					   If (((Get-Service -Name $service_name -ComputerName $server_name).Status) -notlike "Running"){
					   
							If (((Get-Service -Name $service_name -ComputerName $server_name).Status) -like "StartPending"){
								
								write-output "$(get-date) : 	-Start of service is Pending(In Progress). Will check again after $sleeptime seconds " | out-file $LOG_FILE -Append -Force; 
								sleep $sleeptime
							} else {
								Try{
									write-output "$(get-date) : 	-Service($service_name) is neither started nor the start is pending. Hence attempting to Start " | out-file $LOG_FILE -Append -Force; 
									(Get-Service -Name $service_name -ComputerName $server_name).Start()
									sleep $sleeptime
								}Catch{
									write-output "$(get-date) : 	-START COMMAND FAILED  " | out-file $LOG_FILE -Append -Force; 
									#Send-MailMessage -From ExpensesBot@MyCompany.Com -To WinAdmin@MyCompany.Com -Subject "HR File Read Failed!" -SmtpServer EXCH01.AD.MyCompany.Com
									Break
									}
							}
						} else {
								write-output "$(get-date) : Service($service_name) was found in running status. Hence Getting out of loop" | out-file $LOG_FILE -Append -Force; 
								break
						}
				}
			write-output "$(get-date) : Step-B: Status of Service($service_name) before moving on :- $($(get-service -ComputerName $server_name -Name $service_name).Status)" | out-file $LOG_FILE -Append -Force; 
		
			} else {
				write-output "$(get-date) : $service_name : Service was NOT found in stopped status on $server_name" | out-file $LOG_FILE -Append -Force;  
			
			}
				
			} else {
			write-output "$(get-date) : $service_name :no such installed service found on $server_name" | out-file $LOG_FILE -Append -Force;  
				}
		
		}
	}
}


function Find_Genuine_Master_Server($Servers, $Locations){
	$arr_time_stamp_server_wise = @();
	
		for($i=0; $i -lt $Servers.length; $i++){
			
			$this_server=$Servers[$i];
			$this_runfile=$Locations[$i] + "\run.log";
			
			#We are here to get the timestamp mentioned inside run.log file on each server. ChangePath is a function to change the drive
			$tmp_string =Get-content "\\$this_server\$(ChangePath $this_runfile)" | select -First 1
			$tmp = $tmp_string -replace "Starting RedPrairie Store Execution Management ",'' 
			

			$provider = New-Object System.Globalization.CultureInfo "en-US"
			$time_stamp = [datetime]::ParseExact($tmp, '[yyyy-MM-dd HH:mm:ss]', $provider)
			
			$arr_time_stamp_server_wise += $time_stamp;
		}
	
	$oldest_timestamp=$arr_time_stamp_server_wise[0];
	
	

	
	for($i=0; $i -lt $arr_time_stamp_server_wise.length; $i++){
		if( $arr_time_stamp_server_wise[$i] -lt $oldest_timestamp ){
		
			
			$oldest_timestamp=$arr_time_stamp_server_wise[$i];
		}
	}
	

	$indexOfTimeStampInArray= [array]::IndexOf($arr_time_stamp_server_wise, $oldest_timestamp)
	$val=$Servers[$indexOfTimeStampInArray];
	
	#############TEST CASE__REMOVE IT###

#echo "RETURNING MASTER IS  :  $val"

#############TEST CASE__REMOVE IT###

	return "$val";
	
}



function ChangePath($path) {
   $qualifier = Split-Path $path -qualifier
   $drive = $qualifier.substring(0,1)
   $noqualifier = Split-Path $path -noQualifier
   "$drive`$$noqualifier"
}