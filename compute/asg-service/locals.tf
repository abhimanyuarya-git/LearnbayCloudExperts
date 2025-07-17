locals {
  asg_name       = "${var.name}-"
  vpc_subnet_ids = var.subnet_ids

  launch_configuration_name = var.use_lc && var.launch_configuration_name == null ? aws_launch_configuration.launch_configuration[0].name : var.launch_configuration_name
  lt_name                   = coalesce(var.lt_name, var.name)
  launch_template           = !var.use_lc && var.launch_template == null ? aws_launch_template.this[0].name : var.launch_template.name
  launch_template_version   = !var.use_lc && var.launch_template == null ? aws_launch_template.this[0].latest_version : var.launch_template.version

  asg_tags = flatten([for tag, val in merge(var.common_tags, local.ad_tags) :
    {
      key                 = tag
      value               = val
      propagate_at_launch = true
    }
  ])

  keyname            = "${var.name}-ec2-key"
  user_data_received = replace(var.user_data, "</powershell>", "")
  region             = data.aws_region.current.name
  qoute              = "\""
  qoute_plus         = "\",\""
  ad_admin_groups    = var.win_ad_admin_groups == null ? "SEC-GG-SRE-DEV-OPS" : format("%s, %s", var.win_ad_admin_groups, "SEC-GG-SRE-DEV-OPS")
  ssh_ad             = var.ssh_ad_groups == null ? "SEC-GG-SRE-DEV-OPS" : format("%s, %s", var.ssh_ad_groups, "SEC-GG-SRE-DEV-OPS")
  sudo_ad            = var.sudo_ad_groups == null ? "SEC-GG-SRE-DEV-OPS" : format("%s, %s", var.sudo_ad_groups, "SEC-GG-SRE-DEV-OPS")
  str0               = replace(local.ssh_ad, local.qoute, "")
  str1               = lower(replace(local.str0, " ", ""))
  str2               = replace(local.str1, ",", local.qoute_plus)
  ssh_ad_group       = format("\"%s\"", local.str2)
  str00              = replace(local.sudo_ad, local.qoute, "")
  str11              = lower(replace(local.str00, " ", ""))
  str22              = replace(local.str11, ",", local.qoute_plus)
  sudo_ad_group      = format("\"%s\"", local.str22)

  qoute1               = "\""
  qoute1_plus          = "\", \""
  str10                = replace(local.ad_admin_groups, local.qoute1, "")
  str3                 = replace(local.str10, " ", "")
  str4                 = replace(local.str3, ",", local.qoute1_plus)
  win_ad_admin_groups  = format("\"%s\"", local.str4)
  group_check          = replace(local.win_ad_admin_groups, ",", "")
  multi_groups         = local.win_ad_admin_groups == local.group_check ? false : true
  priority_userdata    = replace(var.priority_userdata, "</powershell>", "")
  domain_secrets_arn   = var.ad_secrets_arn
  arcsight_secrets_arn = var.arcsight_secrets_arn
  existing_instances   = local.multi_groups == false ? "powershell.exe -noprofile -executionpolicy bypass -file " : ""
  #new ami
  single_qoute         = "', '"
  single_str           = replace(local.str3, ",", local.single_qoute)
  new_ami_admin_groups = format("'%s'", local.single_str)

  win_swinfra = templatefile("${path.module}/scripts/win-swinfra.ps1", { asg_host_name = local.host_name })
  win_intsaas = templatefile("${path.module}/scripts/win-intsaas.ps1", { asg_host_name = local.host_name })
  win_join_ad = templatefile("${path.module}/scripts/win-join-ad.ps1", { asg_host_name = local.host_name })
  init_join_ad = templatefile("${path.module}/scripts/init.tpl", { host_name = local.host_name
  aws_region = var.aws_region })

  instances_data_linux = <<EOF
runcmd:
  - ${local.update_hostfile} "`hostname` `hostname`.aws.swinfra.net" >> /etc/hosts

EOF

  instances_data_linux_multi = <<EOF
#!/bin/bash
set -ex
[ ! -d /var/log/userdata ] && mkdir /var/log/userdata/
exec > >(tee /var/log/userdata/1_userdata.log|logger -t user-data ) 2>&1
echo 'BEGIN'
date '+%Y-%m-%d %H:%M:%S'

AWS_METADATA_TOKEN=$(curl -sS -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 300")
aws_instance_id=$(curl -H "X-aws-ec2-metadata-token: $AWS_METADATA_TOKEN" -s http://169.254.169.254/latest/meta-data/instance-id | sed "s/ .*//")
hostnum=$((100 + $RANDOM % 400))
newhostname="${local.host_name}$hostnum"

aws ec2 create-tags \
    --resources $${aws_instance_id} \
    --tags Key=hostname,Value=${local.host_name}$${hostnum} Key=Name,Value=${local.host_name}$${hostnum} \
    --region ${var.aws_region}

${local.update_hostfile} "${local.host_name}$${hostnum}   ${local.host_name}$${hostnum}.aws.swinfra.net" >> /etc/hosts


EOF

  instances_data_new_single = <<EOF
#!/bin/bash
set -ex

[ ! -d /var/log/userdata ] && mkdir /var/log/userdata/
exec > >(tee /var/log/userdata/1_userdata.log|logger -t user-data ) 2>&1
echo 'BEGIN'
date '+%Y-%m-%d %H:%M:%S'

EOF

  instances_data_new_multi = <<EOF
#!/bin/bash
set -ex
[ ! -d /var/log/userdata ] && mkdir /var/log/userdata/
exec > >(tee /var/log/userdata/1_userdata.log|logger -t user-data ) 2>&1
echo 'BEGIN'
date '+%Y-%m-%d %H:%M:%S'

AWS_METADATA_TOKEN=$(curl -sS -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 300")
aws_instance_id=$(curl -H "X-aws-ec2-metadata-token: $AWS_METADATA_TOKEN" -s http://169.254.169.254/latest/meta-data/instance-id | sed "s/ .*//")
hostnum=$((100 + $RANDOM % 400))
newhostname="${local.host_name}$hostnum"

aws ec2 create-tags \
    --resources $${aws_instance_id} \
    --tags Key=hostname,Value=${local.host_name}$${hostnum} Key=Name,Value=${local.host_name}$${hostnum} \
    --region ${var.aws_region}

EOF

  instances_data_windows = <<EOF
<powershell>

$HOSTNAME     = ${local.host_name}
${local.win_ad_domain}

${local.priority_userdata}

&'C:\DJT\McAfeeAgentInstaller.exe'
Start-Sleep -s 5
&'C:\DJT\DomainJoiner.exe'
${local.user_data_received}

</powershell>
EOF

  instances_data_windows_multi = <<EOF
<powershell>
$ec2_tags = @"
${local.win_join_ad}

${local.win_ad_domain}
EXIT
"@ 

mkdir C:\DJT\Scripts
$ec2_tags  | Out-File C:\DJT\Scripts\UpdateTags.ps1

&'C:\DJT\Scripts\UpdateTags.ps1'

${local.priority_userdata}

&'C:\DJT\McAfeeAgentInstaller.exe'
Start-Sleep -s 5
&'C:\DJT\DomainJoiner.exe'

${local.user_data_received}

</powershell>
EOF

  windows_data_received = <<EOT
<powershell>
echo "No data Received"
</powershell>
EOT

  key_name        = var.key_pair_name == null ? local.keyname : var.key_pair_name
  host_name       = var.host_name
  data_linux      = var.max_size < 2 ? data.template_cloudinit_config.linux_single.rendered : data.template_cloudinit_config.linux.rendered
  data_windows    = var.max_size < 2 ? base64encode(local.instances_data_windows) : base64encode(local.instances_data_windows_multi)
  update_hostfile = var.update_hostfile && var.ad_domain_prefix == "swinfra" ? "echo" : "####"
  instances_data  = var.windows_instance ? local.data_windows : local.data_linux
  data_received   = var.windows_instance ? local.windows_data_received : local.user_data_received
  win_ad_domain   = var.ad_domain_prefix == "swinfra" ? local.win_swinfra : local.win_intsaas

  ad_tags = {
    "sshers_ad_groups" : "${local.ssh_ad_group}"
    "sudoers_ad_groups" : "${local.sudo_ad_group}"
    "arcsight_secrets_arn" : "${var.arcsight_secrets_arn}"
    "domain_secrets_arn" : "${var.ad_secrets_arn}"
    "admins_ad_groups" : "${trimspace(local.new_ami_admin_groups)}"
    "enable_ip_sec" : "True"
    "Name" : "${local.host_name}"
    "hostname" : "${local.host_name}"
  }

}

data "template_cloudinit_config" "linux" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "00_AD.cfg"
    content_type = "text/cloud-config"
    content      = local.init_join_ad
  }

  # part {
  #   content_type = "text/cloud-config"
  #   content      = local.instances_data_linux
  # }

  part {
    filename     = "part001.sh"
    content_type = "text/x-shellscript"
    content      = local.data_received
  }

}

data "template_cloudinit_config" "linux_single" {
  gzip          = true
  base64_encode = true

  # part {
  #   content_type = "text/cloud-config"
  #   content      = local.instances_data_linux
  # }

  part {
    filename     = "part001.sh"
    content_type = "text/x-shellscript"
    content      = local.data_received
  }

}

