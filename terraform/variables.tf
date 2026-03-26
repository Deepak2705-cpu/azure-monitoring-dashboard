variable "location" {
  description = "Azure region for monitoring resources"
  type        = string
  default     = "East US"
}

variable "teams_webhook_url" {
  description = "Microsoft Teams incoming webhook URL for alert notifications"
  type        = string
  sensitive   = true
}

variable "vm_resource_id" {
  description = "Resource ID of the VM to monitor"
  type        = string
}
