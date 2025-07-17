`$file = "C:\Windows\System32\drivers\etc\hosts"
`$hostfile = Get-Content `$file
`$hostfile += "`$HOSTNAME   `$HOSTNAME.aws.swinfra.net"
Set-Content -Path `$file -Value `$hostfile -Force
