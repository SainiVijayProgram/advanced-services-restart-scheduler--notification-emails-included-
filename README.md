# advanced-services-restart-scheduler--notification-emails-included-

Synopsis

To write a procedure to gracefully shut down the services one after another and then attempt to start them.
Before starting the services, It should be ensured that a service is completely down. So that there should not be any hung process.
This is a good practice for better efficiency of Apache tomcat etc.


Motivation

To fix bugs related to Apache Tomcat

Installation

Host system should have powershell installed.(Tested on powershell 2.0 and higher)

Script is programmed to try $max_trial_allowed number of time and will sleep for $sleeptime seconds before every new trial. Still if the service status do not change, then it can shoot an email to the support team.

Every run of the powershell script will be logged in the SERVERNAME_apache_Restart_Log.log with timestamp

Feel free to use it as per you requirement. Please contact me at VijaySainiProfessional@gmail.com to understand it in more details


Tests

Run the script and read the log(Self explanatory)

