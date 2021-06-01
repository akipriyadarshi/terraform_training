provider "aws" {
  region  = "us-east-2"
}


resource "aws_instance" "instance1" {

  ami                  = "ami-0b9064170e32bde34"
  iam_instance_profile = "${aws_iam_instance_profile.test_profile.name}"
  instance_type        = "t2.micro"
  tags = {
    Name = "instance1"
  }
}

resource "aws_iam_role" "test_role" {
  name = "test_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
      tag-key = "tag-value"
  }
}





resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"
  role = "${aws_iam_role.test_role.name}"
}

resource "aws_iam_role_policy" "test_policy" {
  name = "test_policy"
  role = "${aws_iam_role.test_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::*"
      ]
    }
  ]
}
EOF
}

resource "aws_s3_bucket" "terraakashtests31" {
  bucket = "terraakashtests31"
  acl    = "public-read"

  tags = {
    Name        = "My bucket1"
    
  }
}




