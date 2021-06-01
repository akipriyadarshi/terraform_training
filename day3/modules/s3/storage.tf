resource "aws_s3_bucket" "my_bucket" {
  bucket =  var.bucket
  acl    =  var.acl

  tags = {
    Name        = "My bucket1"
    
  }
}