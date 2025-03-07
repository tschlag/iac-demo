provider "aws" {
  region = "us-east-1"  # Replace with your desired region
}

# Create an S3 bucket
resource "aws_s3_bucket" "example_bucket" {
  bucket = "my-example-bucket"  # Replace with your desired bucket name
  acl    = "private"
}

# Create an IAM role for EC2 with S3 access
resource "aws_iam_role" "ec2_role" {
  name = "ec2-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect    = "Allow"
        Sid       = ""
      },
    ]
  })
}

# Attach the S3 access policy to the EC2 role
resource "aws_iam_policy" "ec2_s3_policy" {
  name        = "ec2-s3-policy"
  description = "Allow EC2 instance to access S3 bucket"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "s3:*"
        Effect   = "Allow"
        Resource = "arn:aws:s3:::my-example-bucket/*"  # Replace with your bucket name
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_s3_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_s3_policy.arn
}

# Create a security group for EC2 instance
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-sg"
  description = "Allow SSH and HTTP"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an EC2 instance
resource "aws_instance" "example_ec2" {
  ami           = "ami-0c55b159cbfafe1f0"  # Replace with your desired AMI ID
  instance_type = "t2.micro"               # Choose your desired instance type
  key_name      = "your-key-pair"          # Replace with your key pair name
  subnet_id     = "subnet-xxxxxxxx"        # Replace with your subnet ID

  security_groups = [aws_security_group.ec2_sg.name]

  iam_instance_profile = aws_iam_role.ec2_role.name

  tags = {
    Name = "EC2-S3-Instance"
  }
}

# Outputs
output "ec2_public_ip" {
  value = aws_instance.example_ec2.public_ip
}

output "s3_bucket_name" {
  value = aws_s3_bucket.example_bucket.bucket
}
