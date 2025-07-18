# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE ALL THE RESOURCES TO DEPLOY AN APP IN AN AUTO SCALING GROUP WITH AN ELB
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

terraform {
  # This module is now only being tested with Terraform 1.1.x. However, to make upgrading easier, we are setting 1.0.0 as the minimum version.
  required_version = ">= 1.0.0"
}

# This Terraform template creates an Auto Scaling Group (ASG) and launch_configuration 

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE ASG
# This defines the number of EC2 Instances to launch
# -----------------------------------------------------------------------------------------------------------------------

resource "aws_autoscaling_group" "asg_group" {
  name_prefix          = local.asg_name
  launch_configuration = var.use_lc ? local.launch_configuration_name : null

  dynamic "launch_template" {
    for_each = var.use_lc == false ? [1] : []

    content {
      name    = local.launch_template
      version = local.launch_template_version
    }
  }

  termination_policies = var.termination_policies

  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  wait_for_capacity_timeout = var.wait_for_capacity_timeout
  min_elb_capacity          = var.min_elb_capacity
  vpc_zone_identifier       = var.subnet_ids

  target_group_arns         = var.target_group_arns
  health_check_type         = var.use_elb_health_checks && (length(var.load_balancers) > 0 || length(var.target_group_arns) > 0) ? "ELB" : "EC2"
  health_check_grace_period = var.health_check_grace_period
  enabled_metrics           = var.enabled_metrics

  dynamic "instance_refresh" {
    for_each = var.instance_refresh != null ? [var.instance_refresh] : []
    content {
      strategy = instance_refresh.value.strategy
      triggers = lookup(instance_refresh.value, "triggers", null)

      dynamic "preferences" {
        for_each = lookup(instance_refresh.value, "preferences", null) != null ? [instance_refresh.value.preferences] : []
        content {
          instance_warmup        = lookup(preferences.value, "instance_warmup", null)
          min_healthy_percentage = lookup(preferences.value, "min_healthy_percentage", null)
        }
      }
    }
  }

  dynamic "tag" {
    for_each = concat(local.asg_tags, var.asg_instance_tags)
    content {
      key                 = tag.value.key
      value               = tag.value.value
      propagate_at_launch = tag.value.propagate_at_launch
    }
  }

  timeouts {
    delete = var.deletion_timeout
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A LAUNCH CONFIGURATION THAT DEFINES EACH EC2 INSTANCE IN THE ASG
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_launch_configuration" "launch_configuration" {
  count = var.use_lc && var.launch_configuration_name == null ? 1 : 0

  name_prefix          = "${var.name}-"
  image_id             = var.ami_id
  instance_type        = var.instance_type
  user_data_base64     = local.instances_data
  iam_instance_profile = var.instance_profile
  enable_monitoring    = var.enable_detailed_monitoring

  key_name                    = local.key_name
  security_groups             = concat([aws_security_group.asg.id], var.additional_security_group_ids)
  placement_tenancy           = var.tenancy
  associate_public_ip_address = var.associate_public_ip_address

  ebs_optimized = var.ebs_optimized

  root_block_device {
    volume_type           = var.root_block_device_volume_type
    volume_size           = var.root_block_device_volume_size
    delete_on_termination = var.root_block_device_delete_on_termination
    encrypted             = true
  }

  metadata_options {
    http_endpoint = "enabled"
    #checkov:skip=CKV_AWS_79:Ensure Instance Metadata Service Version 1 is not enabled
    http_tokens = "optional"
  }

  lifecycle {
    create_before_destroy = true
  }

}

resource "tls_private_key" "ec2_key" {
  count     = var.key_pair_name == null ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  count      = var.key_pair_name == null ? 1 : 0
  key_name   = local.keyname
  public_key = tls_private_key.ec2_key[0].public_key_openssh

}

data "aws_region" "current" {}

resource "aws_autoscaling_schedule" "asg_schedule" {
  for_each               = var.autoscaling_schedule
  scheduled_action_name  = var.autoscaling_schedule[each.key].scheduled_action_name
  min_size               = var.autoscaling_schedule[each.key].min_size
  max_size               = var.autoscaling_schedule[each.key].max_size
  desired_capacity       = var.autoscaling_schedule[each.key].desired_capacity
  recurrence             = var.autoscaling_schedule[each.key].recurrence
  start_time             = var.autoscaling_schedule[each.key].start_time
  end_time               = var.autoscaling_schedule[each.key].end_time
  autoscaling_group_name = aws_autoscaling_group.asg_group.name
}

resource "aws_launch_template" "this" {
  count = var.launch_template == null ? 1 : 0

  name        = var.lt_use_name_prefix ? null : local.lt_name
  name_prefix = var.lt_use_name_prefix ? "${local.lt_name}-" : null
  description = var.description

  ebs_optimized = var.ebs_optimized
  image_id      = var.ami_id
  instance_type = var.instance_type

  key_name  = local.key_name
  user_data = local.instances_data

  vpc_security_group_ids = concat([aws_security_group.asg.id], var.additional_security_group_ids)

  default_version                      = var.default_version
  update_default_version               = var.update_default_version
  disable_api_termination              = var.disable_api_termination
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior
  kernel_id                            = var.kernel_id
  ram_disk_id                          = var.ram_disk_id

  dynamic "block_device_mappings" {
    for_each = var.block_device_mappings
    content {
      device_name  = block_device_mappings.value.device_name
      no_device    = lookup(block_device_mappings.value, "no_device", null)
      virtual_name = lookup(block_device_mappings.value, "virtual_name", null)

      dynamic "ebs" {
        for_each = flatten([lookup(block_device_mappings.value, "ebs", [])])
        content {
          delete_on_termination = lookup(ebs.value, "delete_on_termination", null)
          encrypted             = lookup(ebs.value, "encrypted", null)
          kms_key_id            = lookup(ebs.value, "kms_key_id", null)
          iops                  = lookup(ebs.value, "iops", null)
          throughput            = lookup(ebs.value, "throughput", null)
          snapshot_id           = lookup(ebs.value, "snapshot_id", null)
          volume_size           = lookup(ebs.value, "volume_size", null)
          volume_type           = lookup(ebs.value, "volume_type", null)
        }
      }
    }
  }

  dynamic "capacity_reservation_specification" {
    for_each = var.capacity_reservation_specification != null ? [var.capacity_reservation_specification] : []
    content {
      capacity_reservation_preference = lookup(capacity_reservation_specification.value, "capacity_reservation_preference", null)

      dynamic "capacity_reservation_target" {
        for_each = lookup(capacity_reservation_specification.value, "capacity_reservation_target", [])
        content {
          capacity_reservation_id = lookup(capacity_reservation_target.value, "capacity_reservation_id", null)
        }
      }
    }
  }

  dynamic "cpu_options" {
    for_each = var.cpu_options != null ? [var.cpu_options] : []
    content {
      core_count       = cpu_options.value.core_count
      threads_per_core = cpu_options.value.threads_per_core
    }
  }

  dynamic "credit_specification" {
    for_each = var.credit_specification != null ? [var.credit_specification] : []
    content {
      cpu_credits = credit_specification.value.cpu_credits
    }
  }

  dynamic "elastic_gpu_specifications" {
    for_each = var.elastic_gpu_specifications != null ? [var.elastic_gpu_specifications] : []
    content {
      type = elastic_gpu_specifications.value.type
    }
  }

  dynamic "elastic_inference_accelerator" {
    for_each = var.elastic_inference_accelerator != null ? [var.elastic_inference_accelerator] : []
    content {
      type = elastic_inference_accelerator.value.type
    }
  }

  dynamic "enclave_options" {
    for_each = var.enclave_options != null ? [var.enclave_options] : []
    content {
      enabled = enclave_options.value.enabled
    }
  }

  dynamic "hibernation_options" {
    for_each = var.hibernation_options != null ? [var.hibernation_options] : []
    content {
      configured = hibernation_options.value.configured
    }
  }

  dynamic "iam_instance_profile" {
    for_each = var.instance_profile != null ? [1] : []
    content {
      name = var.instance_profile
    }
  }

  dynamic "instance_market_options" {
    for_each = var.instance_market_options != null ? [var.instance_market_options] : []
    content {
      market_type = instance_market_options.value.market_type

      dynamic "spot_options" {
        for_each = lookup(instance_market_options.value, "spot_options", null) != null ? [instance_market_options.value.spot_options] : []
        content {
          block_duration_minutes         = spot_options.value.block_duration_minutes
          instance_interruption_behavior = lookup(spot_options.value, "instance_interruption_behavior", null)
          max_price                      = lookup(spot_options.value, "max_price", null)
          spot_instance_type             = lookup(spot_options.value, "spot_instance_type", null)
          valid_until                    = lookup(spot_options.value, "valid_until", null)
        }
      }
    }
  }

  dynamic "license_specification" {
    for_each = var.license_specifications != null ? [var.license_specifications] : []
    content {
      license_configuration_arn = license_specifications.value.license_configuration_arn
    }
  }

  dynamic "metadata_options" {
    for_each = var.metadata_options != null ? [var.metadata_options] : []
    content {
      http_endpoint               = lookup(metadata_options.value, "http_endpoint", "enabled")
      http_tokens                 = lookup(metadata_options.value, "http_tokens", "optional")
      http_put_response_hop_limit = lookup(metadata_options.value, "http_put_response_hop_limit", null)
    }
  }

  dynamic "monitoring" {
    for_each = var.enable_detailed_monitoring != null ? [1] : []
    content {
      enabled = var.enable_detailed_monitoring
    }
  }

  dynamic "network_interfaces" {
    for_each = var.network_interfaces
    content {
      associate_carrier_ip_address = lookup(network_interfaces.value, "associate_carrier_ip_address", null)
      associate_public_ip_address  = lookup(network_interfaces.value, "associate_public_ip_address", null)
      delete_on_termination        = lookup(network_interfaces.value, "delete_on_termination", null)
      description                  = lookup(network_interfaces.value, "description", null)
      device_index                 = lookup(network_interfaces.value, "device_index", null)
      ipv4_addresses               = lookup(network_interfaces.value, "ipv4_addresses", null) != null ? network_interfaces.value.ipv4_addresses : []
      ipv4_address_count           = lookup(network_interfaces.value, "ipv4_address_count", null)
      ipv6_addresses               = lookup(network_interfaces.value, "ipv6_addresses", null) != null ? network_interfaces.value.ipv6_addresses : []
      ipv6_address_count           = lookup(network_interfaces.value, "ipv6_address_count", null)
      network_interface_id         = lookup(network_interfaces.value, "network_interface_id", null)
      private_ip_address           = lookup(network_interfaces.value, "private_ip_address", null)
      security_groups              = lookup(network_interfaces.value, "security_groups", null) != null ? network_interfaces.value.security_groups : []
      subnet_id                    = lookup(network_interfaces.value, "subnet_id", null)
    }
  }

  dynamic "placement" {
    for_each = var.placement != null ? [var.placement] : []
    content {
      affinity          = lookup(placement.value, "affinity", null)
      availability_zone = lookup(placement.value, "availability_zone", null)
      group_name        = lookup(placement.value, "group_name", null)
      host_id           = lookup(placement.value, "host_id", null)
      spread_domain     = lookup(placement.value, "spread_domain", null)
      tenancy           = lookup(placement.value, "tenancy", null)
      partition_number  = lookup(placement.value, "partition_number", null)
    }
  }

  dynamic "tag_specifications" {
    for_each = var.tag_specifications
    content {
      resource_type = tag_specifications.value.resource_type
      tags          = tag_specifications.value.tags
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = var.common_tags
  #checkov:skip=CKV_AWS_79:metadata service version 2 is enabled using lookup default values in dynamic metadata block
}
