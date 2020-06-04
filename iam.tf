# creating IAM role.
/*resource "aws_iam_role" "ec2role" {
  name = "ec2s3role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "ec2.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# creating IAM Policy for the role.
resource "aws_iam_policy" "policy" {
  name = "ec2s3policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1591250228672",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectAcl",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

# Attaching policy to role.
resource "aws_iam_policy_attachment" "attachpolicy" {
  name = "attachpolicy"
  roles = [aws_iam_role.ec2role.name]
  policy_arn = aws_iam_policy.policy.arn
}

# Creating IAM instance profile
resource "aws_iam_instance_profile" "iprofile" {
  name = "ec2instanceprofile"
  role = aws_iam_role.ec2role.name

}

output "instanceprofile" {
  value = aws_iam_instance_profile.iprofile.name
}
*/
