# asg-service

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_template"></a> [template](#provider\_template) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.asg_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_autoscaling_policy.scale_in_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy) | resource |
| [aws_autoscaling_policy.scale_out_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy) | resource |
| [aws_autoscaling_schedule.asg_schedule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_schedule) | resource |
| [aws_cloudwatch_metric_alarm.ec2-high-cpu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.ec2-low-cpu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_key_pair.generated_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_launch_configuration.launch_configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_configuration) | resource |
| [aws_launch_template.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_security_group.asg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.ad_ec2_sg_rules](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ec2_sg_prefix_rules](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [tls_private_key.ec2_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [template_cloudinit_config.linux](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/cloudinit_config) | data source |
| [template_cloudinit_config.linux_single](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/cloudinit_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ad_domain_prefix"></a> [ad\_domain\_prefix](#input\_ad\_domain\_prefix) | Name of the domain you want to join e.g. swinfra or intsaas domain. | `string` | n/a | yes |
| <a name="input_ad_secrets_arn"></a> [ad\_secrets\_arn](#input\_ad\_secrets\_arn) | Secret arn for Active Directory for specific region. | `string` | n/a | yes |
| <a name="input_additional_security_group_ids"></a> [additional\_security\_group\_ids](#input\_additional\_security\_group\_ids) | A list of Security Group IDs that should be added to the Launch Configuration and any ENIs, if applicable, created by this module. | `list(string)` | `null` | no |
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | The EC2 instance type to deploy under the ASG. | `string` | n/a | yes |
| <a name="input_arcsight_secrets_arn"></a> [arcsight\_secrets\_arn](#input\_arcsight\_secrets\_arn) | Secret arn for arcsight for specific region. | `string` | n/a | yes |
| <a name="input_asg_instance_tags"></a> [asg\_instance\_tags](#input\_asg\_instance\_tags) | A list of custom tags to apply to the EC2 Instances in this ASG. Each item in this list should be a map with the parameters key, value, and propagate\_at\_launch. | <pre>list(object({<br>    key                 = string<br>    value               = string<br>    propagate_at_launch = bool<br>  }))</pre> | `[]` | no |
| <a name="input_associate_public_ip_address"></a> [associate\_public\_ip\_address](#input\_associate\_public\_ip\_address) | Set to true to associate a public IP address with each server. | `bool` | `false` | no |
| <a name="input_autoscaling_schedule"></a> [autoscaling\_schedule](#input\_autoscaling\_schedule) | Autoscalimg Schedule to start stop instances. | <pre>map(object({<br>    scheduled_action_name = string<br>    min_size              = optional(number)<br>    max_size              = optional(number)<br>    desired_capacity      = optional(number)<br>    recurrence            = optional(string)<br>    start_time            = optional(string)<br>    end_time              = optional(string)<br>  }))</pre> | `{}` | no |
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | Workload AWS Account IDs. | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region in which all resources will be created | `string` | n/a | yes |
| <a name="input_block_device_mappings"></a> [block\_device\_mappings](#input\_block\_device\_mappings) | (LT) Specify volumes to attach to the instance besides the volumes specified by the AMI | `list(any)` | `[]` | no |
| <a name="input_capacity_reservation_specification"></a> [capacity\_reservation\_specification](#input\_capacity\_reservation\_specification) | (LT) Targeting for EC2 capacity reservations | `any` | `null` | no |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | A map of tags to apply to the EC2 instance, security Group and other resources. The key is the tag name and the value is the tag value, these tags will be applied to all resorces. | `map(string)` | n/a | yes |
| <a name="input_cpu_high_threshold"></a> [cpu\_high\_threshold](#input\_cpu\_high\_threshold) | Cloud watch alarm threshold for CPU high metric | `number` | `80` | no |
| <a name="input_cpu_low_threshold"></a> [cpu\_low\_threshold](#input\_cpu\_low\_threshold) | Cloud watch alarm threshold for CPU low metric | `number` | `30` | no |
| <a name="input_cpu_options"></a> [cpu\_options](#input\_cpu\_options) | (LT) The CPU options for the instance | `map(string)` | `null` | no |
| <a name="input_create_lc"></a> [create\_lc](#input\_create\_lc) | Determines whether to create launch configuration or not | `bool` | `false` | no |
| <a name="input_credit_specification"></a> [credit\_specification](#input\_credit\_specification) | (LT) Customize the credit specification of the instance | `map(string)` | `null` | no |
| <a name="input_default_version"></a> [default\_version](#input\_default\_version) | (LT) Default Version of the launch template | `string` | `null` | no |
| <a name="input_deletion_timeout"></a> [deletion\_timeout](#input\_deletion\_timeout) | Timeout value for deletion operations on autoscale groups. | `string` | `"10m"` | no |
| <a name="input_description"></a> [description](#input\_description) | (LT) Description of the launch template | `string` | `null` | no |
| <a name="input_desired_capacity"></a> [desired\_capacity](#input\_desired\_capacity) | The desired capacity of instances under the ASG. | `number` | n/a | yes |
| <a name="input_disable_api_termination"></a> [disable\_api\_termination](#input\_disable\_api\_termination) | (LT) If true, enables EC2 instance termination protection | `bool` | `null` | no |
| <a name="input_ebs_optimized"></a> [ebs\_optimized](#input\_ebs\_optimized) | Set to true to make each server EBS-optimized. | `bool` | `false` | no |
| <a name="input_elastic_gpu_specifications"></a> [elastic\_gpu\_specifications](#input\_elastic\_gpu\_specifications) | (LT) The elastic GPU to attach to the instance | `map(string)` | `null` | no |
| <a name="input_elastic_inference_accelerator"></a> [elastic\_inference\_accelerator](#input\_elastic\_inference\_accelerator) | (LT) Configuration block containing an Elastic Inference Accelerator to attach to the instance | `map(string)` | `null` | no |
| <a name="input_enable_detailed_monitoring"></a> [enable\_detailed\_monitoring](#input\_enable\_detailed\_monitoring) | Enable detailed CloudWatch monitoring for the servers. This gives you more granularity with your CloudWatch metrics, but also costs more money. | `bool` | `false` | no |
| <a name="input_enable_ip_sec"></a> [enable\_ip\_sec](#input\_enable\_ip\_sec) | IP Sec tunnel for windows instance to join AD | `string` | `"True"` | no |
| <a name="input_enabled_metrics"></a> [enabled\_metrics](#input\_enabled\_metrics) | A list of metrics the ASG should enable for monitoring all instances in a group. The allowed values are GroupMinSize, GroupMaxSize, GroupDesiredCapacity, GroupInServiceInstances, GroupPendingInstances, GroupStandbyInstances, GroupTerminatingInstances, GroupTotalInstances. | `list(string)` | `[]` | no |
| <a name="input_enclave_options"></a> [enclave\_options](#input\_enclave\_options) | (LT) Enable Nitro Enclaves on launched instances | `map(string)` | `null` | no |
| <a name="input_health_check_grace_period"></a> [health\_check\_grace\_period](#input\_health\_check\_grace\_period) | Time, in seconds, after an EC2 Instance comes into service before checking health. | `number` | `300` | no |
| <a name="input_hibernation_options"></a> [hibernation\_options](#input\_hibernation\_options) | (LT) The hibernation options for the instance | `map(string)` | `null` | no |
| <a name="input_host_name"></a> [host\_name](#input\_host\_name) | Host Name - this will be used to register the EC2 instance with AD domin. | `string` | n/a | yes |
| <a name="input_instance_initiated_shutdown_behavior"></a> [instance\_initiated\_shutdown\_behavior](#input\_instance\_initiated\_shutdown\_behavior) | (LT) Shutdown behavior for the instance. Can be `stop` or `terminate`. (Default: `stop`) | `string` | `null` | no |
| <a name="input_instance_market_options"></a> [instance\_market\_options](#input\_instance\_market\_options) | (LT) The market (purchasing) option for the instance | `any` | `null` | no |
| <a name="input_instance_profile"></a> [instance\_profile](#input\_instance\_profile) | Instance profile Nmae to use with instance with in asg. | `string` | n/a | yes |
| <a name="input_instance_refresh"></a> [instance\_refresh](#input\_instance\_refresh) | If this block is configured, start an Instance Refresh when this Auto Scaling Group is updated | `any` | `null` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The EC2 instance type to deploy under the ASG. | `string` | n/a | yes |
| <a name="input_kernel_id"></a> [kernel\_id](#input\_kernel\_id) | (LT) The kernel ID | `string` | `null` | no |
| <a name="input_key_pair_name"></a> [key\_pair\_name](#input\_key\_pair\_name) | The name of an EC2 Key Pair to associate with each server for SSH access. Set to null to not associate a Key Pair. | `string` | n/a | yes |
| <a name="input_launch_configuration_name"></a> [launch\_configuration\_name](#input\_launch\_configuration\_name) | The name of the Launch Configuration to use for each EC2 Instance in this ASG. This value MUST be an output of the Launch Configuration resource itself. This ensures a new ASG is created every time the Launch Configuration changes, rolling out your changes automatically. One of var.launch\_configuration\_name or var.launch\_template must be set. | `string` | `null` | no |
| <a name="input_launch_template"></a> [launch\_template](#input\_launch\_template) | The ID and version of the Launch Template to use for each EC2 instance in this ASG. The version value MUST be an output of the Launch Template resource itself. This ensures that a new ASG is created every time a new Launch Template version is created. One of var.launch\_configuration\_name or var.launch\_template must be set. | <pre>object({<br>    name    = string<br>    version = string<br>  })</pre> | `null` | no |
| <a name="input_license_specifications"></a> [license\_specifications](#input\_license\_specifications) | (LT) A list of license specifications to associate with | `map(string)` | `null` | no |
| <a name="input_load_balancers"></a> [load\_balancers](#input\_load\_balancers) | A list of Elastic Load Balancer (ELB) names to associate with this ASG. If you're using the Application Load Balancer (ALB), see var.target\_group\_arns. | `list(string)` | `[]` | no |
| <a name="input_lt_name"></a> [lt\_name](#input\_lt\_name) | Name of launch template to be created | `string` | `""` | no |
| <a name="input_lt_use_name_prefix"></a> [lt\_use\_name\_prefix](#input\_lt\_use\_name\_prefix) | Determines whether to use `lt_name` as is or create a unique name beginning with the `lt_name` as the prefix | `bool` | `true` | no |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | The number of maximum instances under the ASG. | `number` | n/a | yes |
| <a name="input_metadata_options"></a> [metadata\_options](#input\_metadata\_options) | Customize the metadata options for the instance | `map(string)` | <pre>{<br>  "http_endpoint": "enabled",<br>  "http_put_response_hop_limit": "http_put_response_hop_limit",<br>  "http_tokens": "required"<br>}</pre> | no |
| <a name="input_min_elb_capacity"></a> [min\_elb\_capacity](#input\_min\_elb\_capacity) | Wait for this number of EC2 Instances to show up healthy in the load balancer on creation. | `number` | `0` | no |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size) | The number of minumum instances under the ASG. | `number` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name for the ASG and all other resources created by these templates. Must be alphanumeric (A-Za-z0-9), so it cannot contain dashes or underscores. | `string` | n/a | yes |
| <a name="input_network_interfaces"></a> [network\_interfaces](#input\_network\_interfaces) | (LT) Customize network interfaces to be attached at instance boot time | `list(any)` | `[]` | no |
| <a name="input_placement"></a> [placement](#input\_placement) | (LT) The placement of the instance | `map(string)` | `null` | no |
| <a name="input_priority_userdata"></a> [priority\_userdata](#input\_priority\_userdata) | Use this if you need to run your userdata before Windows domain joining script- this is for windows only. | `string` | `"##No Data Passed"` | no |
| <a name="input_ram_disk_id"></a> [ram\_disk\_id](#input\_ram\_disk\_id) | (LT) The ID of the ram disk | `string` | `null` | no |
| <a name="input_root_block_device_delete_on_termination"></a> [root\_block\_device\_delete\_on\_termination](#input\_root\_block\_device\_delete\_on\_termination) | Whether the root volume of each server should be deleted when the server is terminated. | `bool` | `true` | no |
| <a name="input_root_block_device_volume_size"></a> [root\_block\_device\_volume\_size](#input\_root\_block\_device\_volume\_size) | The size, in GB, of the root volume of each server. | `number` | `20` | no |
| <a name="input_root_block_device_volume_type"></a> [root\_block\_device\_volume\_type](#input\_root\_block\_device\_volume\_type) | The type of the root volume of each server. Must be one of: standard, gp2, or io1. | `string` | `"standard"` | no |
| <a name="input_scale_down_count"></a> [scale\_down\_count](#input\_scale\_down\_count) | Number of instances to scale down | `number` | `-1` | no |
| <a name="input_scale_up_count"></a> [scale\_up\_count](#input\_scale\_up\_count) | Number of instances to scale up | `number` | `1` | no |
| <a name="input_security_group_cidr_rules"></a> [security\_group\_cidr\_rules](#input\_security\_group\_cidr\_rules) | Security Group rules with cidr for instances in asg group. | `map(any)` | <pre>{<br>  "all_egress": [<br>    "egress",<br>    "-1",<br>    "0",<br>    "0",<br>    "0.0.0.0/0",<br>    "Wide open egress"<br>  ],<br>  "all_ingress": [<br>    "ingress",<br>    "-1",<br>    "0",<br>    "0",<br>    "0.0.0.0/0",<br>    "Wide open ingress"<br>  ]<br>}</pre> | no |
| <a name="input_security_group_prefix_rules"></a> [security\_group\_prefix\_rules](#input\_security\_group\_prefix\_rules) | Security Group rules with prefix id for instances in asg group. | `map(any)` | `{}` | no |
| <a name="input_ssh_ad_groups"></a> [ssh\_ad\_groups](#input\_ssh\_ad\_groups) | The Active Directory Group to allow access to EC2 instance, for linux only. | `string` | `null` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | A list of Subnets where the ASG. | `list(string)` | n/a | yes |
| <a name="input_sudo_ad_groups"></a> [sudo\_ad\_groups](#input\_sudo\_ad\_groups) | The Active Directory Group to allow access to EC2 instance, for linux only. | `string` | `null` | no |
| <a name="input_tag_specifications"></a> [tag\_specifications](#input\_tag\_specifications) | (LT) The tags to apply to the resources during launch | `list(any)` | `[]` | no |
| <a name="input_target_group_arns"></a> [target\_group\_arns](#input\_target\_group\_arns) | A list of Application Load Balancer (ALB) target group ARNs to associate with this ASG. If you're using the Elastic Load Balancer (ELB), see var.load\_balancers. | `list(string)` | `[]` | no |
| <a name="input_tenancy"></a> [tenancy](#input\_tenancy) | The tenancy of each server. Must be one of: default, dedicated, or host. | `string` | `"default"` | no |
| <a name="input_termination_policies"></a> [termination\_policies](#input\_termination\_policies) | A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, Default. | `list(string)` | `[]` | no |
| <a name="input_update_default_version"></a> [update\_default\_version](#input\_update\_default\_version) | (LT) Whether to update Default Version each update. Conflicts with `default_version` | `string` | `null` | no |
| <a name="input_update_hostfile"></a> [update\_hostfile](#input\_update\_hostfile) | When true, <host name>.swinfra.net entry will be added to the local host file, for swinfra domian only. | `bool` | `true` | no |
| <a name="input_use_elb_health_checks"></a> [use\_elb\_health\_checks](#input\_use\_elb\_health\_checks) | Whether or not ELB or ALB health checks should be enabled. If set to true, the load\_balancers or target\_groups\_arns variable should be set depending on the load balancer type you are using. Useful for testing connectivity before health check endpoints are available. | `bool` | `true` | no |
| <a name="input_use_lc"></a> [use\_lc](#input\_use\_lc) | Determines whether to use a launch configuration in the autoscaling group or not | `bool` | `false` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | The user data to apply to the EC2 instance. | `string` | `""` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC in which to run the ASG and ELB. | `string` | n/a | yes |
| <a name="input_wait_for_capacity_timeout"></a> [wait\_for\_capacity\_timeout](#input\_wait\_for\_capacity\_timeout) | A maximum duration that Terraform should wait for the EC2 Instances to be healthy before timing out. | `string` | `"10m"` | no |
| <a name="input_win_ad_admin_groups"></a> [win\_ad\_admin\_groups](#input\_win\_ad\_admin\_groups) | The Active Directory Group to allow access to EC2 instance, for windows only. | `string` | `null` | no |
| <a name="input_windows_instance"></a> [windows\_instance](#input\_windows\_instance) | true if this is a windows machine. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_asg_arn"></a> [asg\_arn](#output\_asg\_arn) | n/a |
| <a name="output_asg_name"></a> [asg\_name](#output\_asg\_name) | n/a |
| <a name="output_key_pair_public_key"></a> [key\_pair\_public\_key](#output\_key\_pair\_public\_key) | The generated Public Key for the EC2 server. |
| <a name="output_pem"></a> [pem](#output\_pem) | The generated Private Key PEM for the EC2 server. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
