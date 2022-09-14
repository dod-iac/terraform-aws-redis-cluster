variable "apply_immediately" {
  type        = bool
  description = "Specifies whether any modifications are applied immediately, or during the next maintenance window."
  default     = true
}

variable "description" {
  type        = string
  description = "The description of the replication group used by the Redis cluster."
  default     = "A Redis cluster on Amazon ElastiCache."
}

variable "ingress_cidr_blocks" {
  type        = list(string)
  description = "A list of CIDR blocks to allow access to the Redis cluster.  Use [\"0.0.0.0/0\"] to allow all connections within the subnet group."
  default     = []
}

variable "ingress_security_groups" {
  type        = list(string)
  description = "A list of EC2 security groups to allow access to the Redis cluster."
  default     = []
}

variable "number_cache_clusters" {
  type        = number
  description = "The number of cache clusters (primary and replicas) this replication group will have. If Multi-AZ is enabled, the value of this parameter must be at least 2. Updates will occur before other modifications."
  default     = 2
}

variable "node_type" {
  type        = string
  description = "The instance class to be used."
  default     = "cache.m5.large"
}

variable "replication_group_id" {
  type        = string
  description = "The replication group identifier. This parameter is stored as a lowercase string."
}

variable "port" {
  type        = number
  description = "The port number on which each of the cache nodes will accept connections."
  default     = 6379
}

variable "security_group_name" {
  type        = string
  description = "The name of the EC2 security group used by the Redis cluster.  Defaults to redis-[replication_group_id]."
  default     = ""
}

variable "subnet_group_name" {
  type        = string
  description = "The name of the cache subnet group to be used for the replication group."
}

variable "tags" {
  type        = map(string)
  description = "Map of tags to set on the EC2 security group and the ElastiCache replication group."
  default     = {}
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC that the security group will be associated with."
}
