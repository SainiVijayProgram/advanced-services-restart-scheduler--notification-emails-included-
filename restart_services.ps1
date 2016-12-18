#         Script Name : Services_Restart.ps1
#
#                             Developed By: Vijay Saini
#  Scripting Language : PowerShell
#
#                Date : 2nd August 2016
#
#             Purpose : Stop and start Apache services gracefully
#
#             Author  : JDA
#
#             

#Setting up variables
$BASE_DIR="D:\restart_services_walmart"

$host_name=hostname
$ddMMyyyy=(Get-Date).ToString('dd-MM-yyyy');
$LOG_FILE=$BASE_DIR + "\LOG\" +$host_name + "_restart_services-"+$ddMMyyyy +".log"
$html_file=$BASE_DIR + "\LOG\restart_services_email_body.html"

$max_trial_allowed=4
$sleeptime =1
$nl = [Environment]::NewLine


$envt_details=$BASE_DIR + "\" + "script_details.ini" 
$odd_serverlist="";
$even_serverlist="";
$service_list="";
$iis_service_flag="";


$target_servers_for_this_run = @();

#Email Realted
$mail_from=''
$mail_to=''
$mail_cc=''
$success_mail_subject=''
$failure_mail_subject=''
$smtpserver=''


# Starting the script execution
write-output "$(get-date) : Staring the script " | out-file $LOG_FILE -Append -Force;  


$content = Get-Content $envt_details

#Readinig the environment_details.ini file line by line
foreach ($line in $content)
{
	#If the line is containing server's list, assign its values to $server_list variable
	if ( $line -match 'ODD_SERVERLIST'){
		
		$odd_serverlist = $line -replace "ODD_SERVERLIST:-",'' 
		
	}
	
	#If the line is containing server's list, assign its values to $server_list variable
	if ( $line -match 'INCLUDE_IIS_SERVICE'){
		
		$iis_service_flag = $line -replace "INCLUDE_IIS_SERVICE:-",'' 
		
	}
	
	#If the line is containing server's list, assign its values to $server_list variable
	if ( $line -match 'EVEN_SERVERLIST'){
		
		$even_serverlist = $line -replace "EVEN_SERVERLIST:-",'' 
		
	}
	
	#If the line is containing service's list, assign its values to $service_list variable
	if ( $line -match 'SERVICES_LIST'){
		
		$service_list = $line -replace "SERVICES_LIST:-",'' 
		
	}
	
	#Preparing mail variables
	if ( $line -match 'MAIL_FROM'){
		
		$mail_from= $line -replace "MAIL_FROM:-",'' 
		
	}

	#Preparing mail variables
	if ( $line -match 'MAIL_TO'){
		
		$mail_to= $line -replace "MAIL_TO:-",'' 
		
	}

	#Preparing mail variables
	if ( $line -match 'MAIL_CC'){
		
		$mail_cc= $line -replace "MAIL_CC:-",'' 
		
	}

	#Preparing mail variables
	if ( $line -match 'SUCCESS_MAIL_SUBJECT'){
		
		$success_mail_subject= $line -replace "SUCCESS_MAIL_SUBJECT:-",'' 
		
	}

	#Preparing mail variables
	if ( $line -match 'FAILURE_MAIL_SUBJECT'){
		
		$failure_mail_subject= $line -replace "FAILURE_MAIL_SUBJECT:-",'' 
		
	}

	#Preparing mail variables
	if ( $line -match 'SMTPSERVER'){
		
		$smtpserver= $line -replace "SMTPSERVER:-",'' 
		
	}
}

write-output "$(get-date) : Reading configuration file " | out-file $LOG_FILE -Append -Force;  

write-output "$(get-date) : Services list found:     $service_list " | out-file $LOG_FILE -Append -Force;  
write-output "$(get-date) : odd server list found:      $odd_serverlist " | out-file $LOG_FILE -Append -Force;  
write-output "$(get-date) : even server list list found:      $even_serverlist " | out-file $LOG_FILE -Append -Force;  

write-output "$(get-date) : --------------------------------------------------------" | out-file $LOG_FILE -Append -Force;  


#converting string to array
$even_server_list=$even_serverlist -split ',';
$odd_server_list=$odd_serverlist -split ',';
$arr_services=$service_list -split ',';

#echo $arr_all_server_list;
#calling the function files
. $BASE_DIR"\functions_library.ps1"




#Here we are checking the date and on the basis of odd/even, we are transferring the target servers to rest of the script
(Get-Date).Day | % {if($_ % 2 -eq 1 ) {
		$target_servers_for_this_run=$odd_server_list;
		} else {
		$target_servers_for_this_run=$even_server_list;
	}
}

write-output "$(get-date) : -------------------------------------------------------- " | out-file $LOG_FILE -Append -Force;  
write-output "$(get-date) : target_servers_for_this_run : $target_servers_for_this_run " | out-file $LOG_FILE -Append -Force;  
write-output "$(get-date) : Services to restart : $arr_services " | out-file $LOG_FILE -Append -Force;  

#STEP I
#Stopping the services on all servers
write-output "$(get-date) : Stoppping the Services" | out-file $LOG_FILE -Append -Force;  
Stop_Specified_Services $target_servers_for_this_run $arr_services;


#For stopping the services we will use INVOKE Command
#Invoke-Command -ComputerName $target_servers_for_this_run -scriptblock ${function:Foo}



#STEP II
#Restrting IIS if it is enabled for restart in config file
if($iis_service_flag.CompareTo("TRUE") -eq 0){
write-output "$(get-date) : Restarting IIS" | out-file $LOG_FILE -Append -Force;  

	#invoke-command -computername "TARGET-HOST" -scriptblock {iisreset /RESTART}
	#Invoke-Command $target_servers_for_this_run -ScriptBlock { iisreset /restart  } | Out-File -Append $LOG_FILE

}


#STEP III
#Starting the services 
#Not starting if the service is not found in 'Stopped' status
write-output "$(get-date) :Starting the services" | out-file $LOG_FILE -Append -Force;  

Start_Specified_Services $target_servers_for_this_run $arr_services;

#Final validation

$err_msg="";

write-output "$(get-date) : Validating the Started services on Master Server" | out-file $LOG_FILE -Append -Force;  
foreach ($server in $target_servers_for_this_run){

	foreach ($service_name in $arr_services){
	
			If (((Get-Service -Name $service_name -ComputerName $server).Status) -notlike "Running"){
				$err_msg ="$err_msg --> $service_name Service was not found in running status on Server name:  $server <br>";
			} 
		}
}


write-output "*************** " | out-file $LOG_FILE -Append -Force;  
write-output "$(get-date) :	$err_msg" | out-file $LOG_FILE -Append -Force;  
write-output "*************** " | out-file $LOG_FILE -Append -Force;  

write-output "$(get-date) :Script Execution completed. Preparing Email body now " | out-file $LOG_FILE -Append -Force;  


#Preparing email body
"">$html_file
write-output "<html><br>" | out-file $html_file -Append -Force; 
write-output "<body><br>" | out-file $html_file -Append -Force; 
write-output "Hi Team,<br><br>" | out-file $html_file -Append -Force; 

write-output "<br>" | out-file $html_file -Append -Force; 

if ($err_msg.length -gt 0) {
$Subject=$failure_mail_subject;
	write-output "<font color='red'><b>Attention Application Team <b></font><br><br>" | out-file $html_file -Append -Force; 
	write-output "This is to notify you that scheduled restart of services was executed and it have been completed with following errors:-<br><br>" | out-file $html_file -Append -Force; 
	write-output "$err_msg <br>" | out-file $html_file -Append -Force; 
} else {
$Subject=$success_mail_subject;
	write-output "<font color='greeen'> This is to notify you that scheduled restart of services was executed and is completed successfully</font><br><br>" | out-file $html_file -Append -Force; 
}

write-output "<br>Please find attached log for more information" | out-file $html_file -Append -Force; 
	
write-output "<br><br>Regards,<br>" | out-file $html_file -Append -Force; 
write-output "<br><br>Regards,<br>" | out-file $html_file -Append -Force; 
write-output "JDA Support<br>" | out-file $html_file -Append -Force; 


write-output "$_$nl$_$nl" | out-file $LOG_FILE -Append -Force; 



###############################################################################
Sleep $sleeptime;


$body = get-content .\LOG\restart_services_email_body.html
$attachment = "$LOG_FILE"

 
#################################### 

$message = new-object System.Net.Mail.MailMessage
$message.From = $mail_from
$message.To.Add($mail_to)
$message.CC.Add($mail_cc)
$message.IsBodyHtml = $True
$attach = new-object Net.Mail.Attachment($attachment)
$message.Attachments.Add($attach)
$message.body = $body

$smtp = new-object Net.Mail.SmtpClient($smtpserver)
$message.Subject = $Subject

if ($err_msg.length -gt 0) {
	#SEND FAILURE EMAILS
	$smtp.Send($message)
} else {
	#SEND SUCCCESS EMAILS
	#$smtp.Send($message)
}



##################################################################################