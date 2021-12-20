variable "ec2_ids_list" {
  description = "Lista de IDs das instâncias EC2 onde será anexado o instance profile."
  type        = list(string)
}

variable "instance_profile_role_name" {
  description = "Nome do instance profile que permitira o SSM gerenciar a instância EC2."
  type        = string
  default     = "CloneAmazonSSMRoleForInstancesQuickSetup"
}

variable "instance_profile_role_description" {
  type    = string
  default = "Instance profile que permitira o SSM gerenciar a instância EC2."
}

variable "iam_role_for_ssm_automation_name" {
  description = "Nome do IAM role que permite o SSM executar automações."
  type        = string
  default     = "CloneAmazonSSMRoleForAutomationAssumeQuickSetup"
}

variable "iam_role_for_ssm_automation_description" {
  type    = string
  default = "IAM role que permite o SSM realizar automações."
}

variable "policy_for_ssm_automation_name" {
  description = "Nome da policy que permite o SSM realizar automações."
  type        = string
  default     = "CloneSSSMOnboardingInlinePolicyAndQuickSetup"
}

