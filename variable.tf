/*variable "private_subnet_a" {
  type = string
  default = "subnet-04b0f128dede17494"
 }
 
 variable "private_subnet_b" {
  type = string
  default = "subnet-064387167bf1f9e7d"
 }
*/
 variable "private_access" {
  type        = bool
  default     = true
  description = "Enable or disable private endpoint access for the EKS cluster"
}