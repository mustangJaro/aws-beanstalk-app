resource "aws_security_group" "this" {
  name   = local.resource_name
  vpc_id = local.vpc_id
  tags   = merge(local.tags, { Name = local.resource_name })
}

// See https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-prerequisites.html
// In order for SSM to work properly, HTTPS (443) oubound must be allowed for
//   - ec2messages.<region>.amazonaws.com
//   - ssm.<region>.amazonaws.com
//   - ssmmessages.<region>.amazonaws.com
resource "aws_security_group_rule" "this-https-to-world" {
  security_group_id = aws_security_group.this.id
  type              = "egress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["0.0.0.0/0"]
}
