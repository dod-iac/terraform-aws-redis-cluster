/**
 * ## Usage
 *
 * Creates a Elasticache Redis cluster.
 *
 * ```hcl
 * module "vpc" {
 *   source  = "terraform-aws-modules/vpc/aws"
 *   version = "3.14.2"
 *
 *   ...
 *   create_elasticache_subnet_group = true
 *   create_elasticache_subnet_route_table = true
 *   elasticache_subnets = ["10.0.201.0/24", "10.0.202.0/24", "10.0.203.0/24"]
 *   ...
 * }
 *
 * module "redis_cluster" {
 *   source = "dod-iac/redis-cluster/aws"
 *
 *   ingress_cidr_blocks  = ["0.0.0.0/0"]
 *   replication_group_id = format("test-%s", var.test_name)
 *   subnet_group_name    = module.vpc.elasticache_subnet_group_name
 *   vpc_id               = module.vpc.vpc_id
 * }
 *
 * ```
 *
 * ## Testing
 *
 * Run all terratest tests using the `terratest` script.  If using `aws-vault`, you could use `aws-vault exec $AWS_PROFILE -- terratest`.  The `AWS_DEFAULT_REGION` environment variable is required by the tests.  Use `TT_SKIP_DESTROY=1` to not destroy the infrastructure created during the tests.  Use `TT_VERBOSE=1` to log all tests as they are run.  Use `TT_TIMEOUT` to set the timeout for the tests, with the value being in the Go format, e.g., 15m.  Use `TT_TEST_NAME` to run a specific test by name.
 *
 * ## Terraform Version
 *
 * Terraform 0.13. Pin module version to ~> 1.0.0 . Submit pull-requests to main branch.
 *
 * Terraform 0.11 and 0.12 are not supported.
 *
 * ## Upgrade Notes
 *
 * ### 1.0.x to 1.1.x
 *
 * In 1.1.x, the cluster no longer allows ingress by default.  Allow ingress for all connections in the subnet by setting `ingress_cidr_blocks` to `["0.0.0.0/0"]`.
 *
 * ## License
 *
 * This project constitutes a work of the United States Government and is not subject to domestic copyright protection under 17 USC § 105.  However, because the project utilizes code licensed from contributors and other third parties, it therefore is licensed under the MIT License.  See LICENSE file for more information.
 */

data "aws_region" "current" {}

resource "aws_security_group" "main" {
  name        = length(var.security_group_name) > 0 ? var.security_group_name : format("redis-%s", var.replication_group_id)
  description = "Security group for Redis cluster"
  tags        = var.tags
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "ingress_cidr_blocks" {
  count = length(var.ingress_cidr_blocks) > 0 ? 1 : 0

  security_group_id = aws_security_group.main.id
  type              = "ingress"
  from_port         = var.port
  to_port           = var.port
  protocol          = "tcp"

  cidr_blocks = var.ingress_cidr_blocks
}

resource "aws_security_group_rule" "ingress_security_groups" {
  count = length(var.ingress_security_groups)

  security_group_id = aws_security_group.main.id
  type              = "ingress"
  from_port         = var.port
  to_port           = var.port
  protocol          = "tcp"

  source_security_group_id = var.ingress_security_groups[count.index]
}

resource "aws_security_group_rule" "egress" {
  security_group_id = aws_security_group.main.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_elasticache_replication_group" "main" {
  apply_immediately          = var.apply_immediately
  at_rest_encryption_enabled = true
  automatic_failover_enabled = true
  availability_zones = slice(
    formatlist(format("%s%%s", data.aws_region.current.name), ["a", "b", "c"]),
    0,
    var.number_cache_clusters
  )
  multi_az_enabled              = true
  node_type                     = var.node_type
  number_cache_clusters         = var.number_cache_clusters
  parameter_group_name          = "default.redis6.x"
  port                          = var.port
  replication_group_id          = var.replication_group_id
  replication_group_description = "Replication group for the index of raw files"
  security_group_ids            = [aws_security_group.main.id]
  subnet_group_name             = var.subnet_group_name
  tags                          = var.tags
  transit_encryption_enabled    = true

  lifecycle {
    ignore_changes = [number_cache_clusters]
  }
}
