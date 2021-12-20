terraform {
  backend "s3" {
    bucket                  = "team42-terraform-states"
    key                     = "terraform.tfstate"
    region                  = "us-east-1"
    profile                 = "team-42"
    shared_credentials_file = "$HOME/.aws/credentials"
  }
  required_version = "> 0.12.0"
}

provider "aws" {
  region = "us-east-1"
}

# Begin: Role for EC2
resource "aws_iam_role" "ssm_role_for_ec2" {
  name               = var.instance_profile_role_name
  description        = var.instance_profile_role_description
  assume_role_policy = file("./policies/ec2trustpolicy.json")
}

resource "aws_iam_role_policy_attachment" "ssm_managed_policy" {
  role       = aws_iam_role.ssm_role_for_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
# End: Role for EC2

# Begin: Role for SSM Automation
resource "aws_iam_role" "ssm_role_for_automation" {
  name               = var.iam_role_for_ssm_automation_name
  description        = var.iam_role_for_ssm_automation_description
  assume_role_policy = file("./policies/ssmtrustpolicy.json")
}

resource "aws_iam_role_policy" "ssm_quick_setup" {
  name = var.policy_for_ssm_automation_name
  role = aws_iam_role.ssm_role_for_automation.id

  policy = file("./policies/ssmquicksetup.json")
}
# End: Role for SSM Automation

resource "null_resource" "previous" {}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [null_resource.previous]

  create_duration = "30s"
}

resource "aws_ssm_association" "attach_iam_to_ec2_automation" {
  name             = "AWS-AttachIAMToInstance"
  association_name = "AttachIAMtoEc2Association"

  automation_target_parameter_name = "InstanceId"
  targets {
    key    = "ParameterValues"
    values = var.ec2_ids_list
  }

  parameters = {
    RoleName             = aws_iam_role.ssm_role_for_ec2.name
    AutomationAssumeRole = aws_iam_role.ssm_role_for_automation.arn
    ForceReplace         = true
  }

  depends_on = [time_sleep.wait_30_seconds]
}

resource "aws_ssm_association" "update_ssm_agent_automation" {
  count               = 0
  name                = "AWS-UpdateSSMAgent"
  association_name    = "UpdateSSMAgentAssociation"
  schedule_expression = "rate(14 days)"

  targets {
    key    = "InstanceIds"
    values = ["*"]
  }
}
