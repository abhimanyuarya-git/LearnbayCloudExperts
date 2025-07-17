bootcmd: 
  - [ cloud-init-per, instance, getToken, sh, -xc, "AWS_METADATA_TOKEN=$(curl -sS -X PUT 'http://169.254.169.254/latest/api/token' -H 'X-aws-ec2-metadata-token-ttl-seconds: 300') \
  && aws_instance_id=$(curl -H \"X-aws-ec2-metadata-token: $AWS_METADATA_TOKEN\" -v http://169.254.169.254/latest/meta-data/instance-id) \
  && hostnum=$(date +'%S%1N') \
  && newhostname=\"${host_name}\"$hostnum \
  && aws ec2 create-tags --resources $aws_instance_id --tags Key=hostname,Value=$newhostname Key=Name,Value=$newhostname --region ${aws_region}" ]
