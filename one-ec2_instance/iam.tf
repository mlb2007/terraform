# create a iam policy document that specifies actions to be 
# performed, resources that can be accessed 
resource "aws_iam_policy" "ec2-instance-policy" {
  name   = "ec2_instance_policy"
  path = "/"
  description = "Permissions policy"
  policy = file("policies/ec2-instance-policy.json")
}

# create a role and assign who to trust
resource "aws_iam_role" "ec2-instance-role" {
  name               = "ec2_instance_role"
  assume_role_policy = file("policies/ec2-role-trust-policy.json")
}

# attach policy document with the role created
resource "aws_iam_policy_attachment" "ec2-policy-attach" {
   name = "ec2-policy-attachment"
   roles = [aws_iam_role.ec2-instance-role.name]
   policy_arn = aws_iam_policy.ec2-instance-policy.arn
}

# For attaching the role for EC2 instances or ECS services
# we need to create something called aws_iam_instance_profile
# which is the one we attach as role to Ec2 instance created
#
resource "aws_iam_instance_profile" "ec2-role-summary" {
  name = "ecs_instance_profile_summary"
  role = aws_iam_role.ec2-instance-role.name
}
