# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These variables are expected to be passed in by the operator
# ---------------------------------------------------------------------------------------------------------------------

variable "aws_region" {
  description = "The AWS region in which all resources will be created"
  type        = string
}

variable "aws_account_id" {
  description = "Workload AWS Account IDs."
  type        = string
}

variable "name" {
  description = "The name for the ASG and all other resources created by these templates. Must be alphanumeric (A-Za-z0-9), so it cannot contain dashes or underscores."
  type        = string
}

variable "ami_id" {
  description = "The EC2 instance type to deploy under the ASG."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC in which to run the ASG and ELB."
  type        = string
}

variable "subnet_ids" {
  description = "A list of Subnets where the ASG."
  type        = list(string)
}

variable "instance_type" {
  description = "The EC2 instance type to deploy under the ASG."
  type        = string
}

variable "min_size" {
  description = "The number of minumum instances under the ASG."
  type        = number
}

variable "max_size" {
  description = "The number of maximum instances under the ASG."
  type        = number
}

variable "desired_capacity" {
  description = "The desired capacity of instances under the ASG."
  type        = number
}

variable "instance_profile" {
  description = "Instance profile Nmae to use with instance with in asg."
  type        = string

}

variable "common_tags" {
  description = "A map of tags to apply to the EC2 instance, security Group and other resources. The key is the tag name and the value is the tag value, these tags will be applied to all resorces."
  type        = map(string)
}

variable "key_pair_name" {
  description = "The name of an EC2 Key Pair to associate with each server for SSH access. Set to null to not associate a Key Pair."
  type        = string
}


variable "arcsight_secrets_arn" {
  type        = string
  description = "Secret arn for arcsight for specific region."
}

variable "ad_secrets_arn" {
  type        = string
  description = "Secret arn for Active Directory for specific region."
}

variable "host_name" {
  type        = string
  description = "Host Name - this will be used to register the EC2 instance with AD domin."
  validation {
    condition     = (length(var.host_name) <= 13 && can(regex("^[A-Za-z][0-9A-Za-z-]+$", var.host_name)))
    error_message = "Hostname must be max 13 and allowed chars are: '^(?![0-9]{1,12}$)[a-zA-Z0-9-]{1,12}$'."
  }
}

variable "termination_policies" {
  description = "A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, Default."
  type        = list(string)
  default     = []
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "load_balancers" {
  description = "A list of Elastic Load Balancer (ELB) names to associate with this ASG. If you're using the Application Load Balancer (ALB), see var.target_group_arns."
  type        = list(string)
  default     = []
}

variable "target_group_arns" {
  description = "A list of Application Load Balancer (ALB) target group ARNs to associate with this ASG. If you're using the Elastic Load Balancer (ELB), see var.load_balancers."
  type        = list(string)
  default     = []
}

variable "min_elb_capacity" {
  description = "Wait for this number of EC2 Instances to show up healthy in the load balancer on creation."
  type        = number
  default     = 0
}

variable "use_elb_health_checks" {
  description = "Whether or not ELB or ALB health checks should be enabled. If set to true, the load_balancers or target_groups_arns variable should be set depending on the load balancer type you are using. Useful for testing connectivity before health check endpoints are available."
  type        = bool
  default     = true
}

variable "health_check_grace_period" {
  description = "Time, in seconds, after an EC2 Instance comes into service before checking health."
  type        = number
  default     = 300
}

variable "wait_for_capacity_timeout" {
  description = "A maximum duration that Terraform should wait for the EC2 Instances to be healthy before timing out."
  type        = string
  default     = "10m"
}

variable "enabled_metrics" {
  description = "A list of metrics the ASG should enable for monitoring all instances in a group. The allowed values are GroupMinSize, GroupMaxSize, GroupDesiredCapacity, GroupInServiceInstances, GroupPendingInstances, GroupStandbyInstances, GroupTerminatingInstances, GroupTotalInstances."
  type        = list(string)
  default     = []

  # Example:
  # enabled_metrics = [
  #    "GroupDesiredCapacity",
  #    "GroupInServiceInstances",
  #    "GroupMaxSize",
  #    "GroupMinSize",
  #    "GroupPendingInstances",
  #    "GroupStandbyInstances",
  #    "GroupTerminatingInstances",
  #    "GroupTotalInstances"
  #  ]
}

variable "asg_instance_tags" {
  description = "A list of custom tags to apply to the EC2 Instances in this ASG. Each item in this list should be a map with the parameters key, value, and propagate_at_launch."
  type = list(object({
    key                 = string
    value               = string
    propagate_at_launch = bool
  }))
  default = []

  # Example:
  # default = [
  #   {
  #     key = "foo"
  #     value = "bar"
  #     propagate_at_launch = true
  #   },
  #   {
  #     key = "baz"
  #     value = "blah"
  #     propagate_at_launch = true
  #   }
  # ]
}

variable "additional_security_group_ids" {
  description = "A list of Security Group IDs that should be added to the Launch Configuration and any ENIs, if applicable, created by this module."
  type        = list(string)
  default     = null
}

variable "deletion_timeout" {
  description = "Timeout value for deletion operations on autoscale groups."
  type        = string
  default     = "10m"
}

variable "root_block_device_volume_type" {
  description = "The type of the root volume of each server. Must be one of: standard, gp2, or io1."
  type        = string
  default     = "standard"
}

variable "root_block_device_volume_size" {
  description = "The size, in GB, of the root volume of each server."
  type        = number
  default     = 20
}

variable "root_block_device_delete_on_termination" {
  description = "Whether the root volume of each server should be deleted when the server is terminated."
  type        = bool
  default     = true
}

variable "ebs_optimized" {
  description = "Set to true to make each server EBS-optimized."
  type        = bool
  default     = false
}

variable "tenancy" {
  description = "The tenancy of each server. Must be one of: default, dedicated, or host."
  type        = string
  default     = "default"
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring for the servers. This gives you more granularity with your CloudWatch metrics, but also costs more money."
  type        = bool
  default     = false
}

variable "associate_public_ip_address" {
  description = "Set to true to associate a public IP address with each server."
  type        = bool
  default     = false
}

variable "security_group_prefix_rules" {
  description = "Security Group rules with prefix id for instances in asg group."
  type        = map(any)
  default     = {}
}

variable "security_group_cidr_rules" {
  description = "Security Group rules with cidr for instances in asg group."
  type        = map(any)
  default = {
    all_egress  = ["egress", "-1", "0", "0", "0.0.0.0/0", "Wide open egress"]
    all_ingress = ["ingress", "-1", "0", "0", "0.0.0.0/0", "Wide open ingress"]
  }
}

variable "enable_ip_sec" {
  type        = string
  description = "IP Sec tunnel for windows instance to join AD"
  default     = "True"
}

variable "windows_instance" {
  type        = bool
  description = "true if this is a windows machine."
  default     = false
}

variable "win_ad_admin_groups" {
  type        = string
  description = "The Active Directory Group to allow access to EC2 instance, for windows only."
  default     = null
}

variable "ssh_ad_groups" {
  type        = string
  description = "The Active Directory Group to allow access to EC2 instance, for linux only."
  default     = null
}

variable "sudo_ad_groups" {
  type        = string
  description = "The Active Directory Group to allow access to EC2 instance, for linux only."
  default     = null
}

variable "update_hostfile" {
  description = "When true, <host name>.swinfra.net entry will be added to the local host file, for swinfra domian only."
  type        = bool
  default     = true
}

variable "user_data" {
  description = "The user data to apply to the EC2 instance."
  type        = string
  default     = ""
}

variable "priority_userdata" {
  type        = string
  description = "Use this if you need to run your userdata before Windows domain joining script- this is for windows only."
  default     = "##No Data Passed"
}

variable "metadata_options" {
  description = "Customize the metadata options for the instance"
  type        = map(string)
  default = {
    "http_endpoint"               = "enabled",
    "http_tokens"                 = "required",
    "http_put_response_hop_limit" = "http_put_response_hop_limit"
  }
}

variable "ad_domain_prefix" {
  type        = string
  description = "Name of the domain you want to join e.g. swinfra or intsaas domain."
}

variable "autoscaling_schedule" {
  description = "Autoscalimg Schedule to start stop instances."
  type = map(object({
    scheduled_action_name = string
    min_size              = optional(number)
    max_size              = optional(number)
    desired_capacity      = optional(number)
    recurrence            = optional(string)
    start_time            = optional(string)
    end_time              = optional(string)
  }))
  default = {}
}


################################################################################
# Launch configuration
################################################################################

variable "create_lc" {
  description = "Determines whether to create launch configuration or not"
  type        = bool
  default     = false
}

variable "use_lc" {
  description = "Determines whether to use a launch configuration in the autoscaling group or not"
  type        = bool
  default     = false
}

variable "launch_configuration_name" {
  description = "The name of the Launch Configuration to use for each EC2 Instance in this ASG. This value MUST be an output of the Launch Configuration resource itself. This ensures a new ASG is created every time the Launch Configuration changes, rolling out your changes automatically. One of var.launch_configuration_name or var.launch_template must be set."
  type        = string
  default     = null
}

################################################################################
# Launch template
################################################################################
variable "launch_template" {
  description = "The ID and version of the Launch Template to use for each EC2 instance in this ASG. The version value MUST be an output of the Launch Template resource itself. This ensures that a new ASG is created every time a new Launch Template version is created. One of var.launch_configuration_name or var.launch_template must be set."
  type = object({
    name    = string
    version = string
  })
  default = null
}

variable "lt_name" {
  description = "Name of launch template to be created"
  type        = string
  default     = ""
}

variable "lt_use_name_prefix" {
  description = "Determines whether to use `lt_name` as is or create a unique name beginning with the `lt_name` as the prefix"
  type        = bool
  default     = true
}

variable "description" {
  description = "(LT) Description of the launch template"
  type        = string
  default     = null
}

variable "default_version" {
  description = "(LT) Default Version of the launch template"
  type        = string
  default     = null
}

variable "update_default_version" {
  description = "(LT) Whether to update Default Version each update. Conflicts with `default_version`"
  type        = string
  default     = null
}

variable "disable_api_termination" {
  description = "(LT) If true, enables EC2 instance termination protection"
  type        = bool
  default     = null
}

variable "instance_initiated_shutdown_behavior" {
  description = "(LT) Shutdown behavior for the instance. Can be `stop` or `terminate`. (Default: `stop`)"
  type        = string
  default     = null
}

variable "kernel_id" {
  description = "(LT) The kernel ID"
  type        = string
  default     = null
}

variable "ram_disk_id" {
  description = "(LT) The ID of the ram disk"
  type        = string
  default     = null
}

variable "block_device_mappings" {
  description = "(LT) Specify volumes to attach to the instance besides the volumes specified by the AMI"
  type        = list(any)
  default     = []
}

variable "capacity_reservation_specification" {
  description = "(LT) Targeting for EC2 capacity reservations"
  type        = any
  default     = null
}

variable "cpu_options" {
  description = "(LT) The CPU options for the instance"
  type        = map(string)
  default     = null
}

variable "credit_specification" {
  description = "(LT) Customize the credit specification of the instance"
  type        = map(string)
  default     = null
}

variable "elastic_gpu_specifications" {
  description = "(LT) The elastic GPU to attach to the instance"
  type        = map(string)
  default     = null
}

variable "elastic_inference_accelerator" {
  description = "(LT) Configuration block containing an Elastic Inference Accelerator to attach to the instance"
  type        = map(string)
  default     = null
}

variable "enclave_options" {
  description = "(LT) Enable Nitro Enclaves on launched instances"
  type        = map(string)
  default     = null
}

variable "hibernation_options" {
  description = "(LT) The hibernation options for the instance"
  type        = map(string)
  default     = null
}

variable "instance_market_options" {
  description = "(LT) The market (purchasing) option for the instance"
  type        = any
  default     = null
}

variable "license_specifications" {
  description = "(LT) A list of license specifications to associate with"
  type        = map(string)
  default     = null
}

variable "network_interfaces" {
  description = "(LT) Customize network interfaces to be attached at instance boot time"
  type        = list(any)
  default     = []
}

variable "placement" {
  description = "(LT) The placement of the instance"
  type        = map(string)
  default     = null
}

variable "tag_specifications" {
  description = "(LT) The tags to apply to the resources during launch"
  type        = list(any)
  default     = []
}

variable "instance_refresh" {
  description = "If this block is configured, start an Instance Refresh when this Auto Scaling Group is updated"
  type        = any
  default     = null
}

variable "cpu_high_threshold" {
  description = "Cloud watch alarm threshold for CPU high metric"
  type        = number
  default     = 80
}

variable "cpu_low_threshold" {
  description = "Cloud watch alarm threshold for CPU low metric"
  type        = number
  default     = 30
}

variable "scale_up_count" {
  description = "Number of instances to scale up"
  type        = number
  default     = 1
}

variable "scale_down_count" {
  description = "Number of instances to scale down"
  type        = number
  default     = -1
}