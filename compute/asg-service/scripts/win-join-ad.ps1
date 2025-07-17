Install-Module -Name AWSPowerShell -Force 

`$hostnum  = Get-Random -Minimum 100 -Maximum 999
`$HOSTNAME     = "${asg_host_name}`$hostnum"

[string]`$token = Invoke-RestMethod -Headers @{"X-aws-ec2-metadata-token-ttl-seconds" = "21600"} -Method PUT -Uri http://169.254.169.254/latest/api/token
[string]`$ID    = Invoke-RestMethod -Headers @{"X-aws-ec2-metadata-token" = `$token} -Method GET -Uri http://169.254.169.254/latest/meta-data/instance-id

New-EC2Tag -Resource `$ID  -Tag @{ Key = "hostname"; Value = `$HOSTNAME } -Force 
