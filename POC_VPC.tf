terraform {
  backend "s3" {
    bucket         = "terraform-st-track"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "MY_POC_VPC" {
  cidr_block = "10.0.0.0/23"
  tags = {
    Name = "MY_POC_VPC"
  }
}

resource "aws_subnet" "POC_Public_subnet_1" {
  vpc_id     = aws_vpc.MY_POC_VPC.id
  cidr_block = "10.0.0.0/25"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "POC_Public_subnet_1"
  }
}
resource "aws_subnet" "POC_Public_subnet_2" {
  vpc_id     = aws_vpc.MY_POC_VPC.id
  cidr_block = "10.0.0.128/25"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "POC_Public_subnet_2"
  }
}
resource "aws_subnet" "POC_Private_subnet_1" {
  vpc_id     = aws_vpc.MY_POC_VPC.id
  cidr_block = "10.0.1.0/25"

  tags = {
    Name = "POC_Private_subnet_1"
  }
}
resource "aws_subnet" "POC_Private_subnet_2" {
  vpc_id     = aws_vpc.MY_POC_VPC.id
  cidr_block = "10.0.1.128/25"

  tags = {
    Name = "POC_Private_subnet_2"
  }
}



resource "aws_internet_gateway" "Internet_Gateway_vpc" {
  vpc_id = aws_vpc.MY_POC_VPC.id

  tags = {
    Name = "POC_Internet_Gateway_vpc"
  }
}

resource "aws_eip" "POC_auto_eip" {


}

resource "aws_nat_gateway" "POC_NGW" {
  allocation_id = aws_eip.POC_auto_eip.id
  subnet_id     = aws_subnet.POC_Public_subnet_1.id

  tags = {
    Name = "POC_NGW"
  }
}

resource "aws_route_table" "POC_Public_route_table" {
  vpc_id = aws_vpc.MY_POC_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Internet_Gateway_vpc.id
  }


  tags = {
    Name = "POC_Public_route_table"
  }
}

resource "aws_route_table" "POC_Private_route_table" {
  vpc_id = aws_vpc.MY_POC_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.POC_NGW.id
  }


  tags = {
    Name = "POC_Private_route_table"
  }
}


resource "aws_route_table_association" "POC_Public" {
  subnet_id      = aws_subnet.POC_Public_subnet_1.id
  route_table_id = aws_route_table.POC_Public_route_table.id
}

resource "aws_route_table_association" "POC_Public2" {
  subnet_id      = aws_subnet.POC_Public_subnet_2.id
  route_table_id = aws_route_table.POC_Public_route_table.id
}

resource "aws_route_table_association" "POC_Private" {
  subnet_id      = aws_subnet.POC_Private_subnet_1.id
  route_table_id = aws_route_table.POC_Private_route_table.id
}

resource "aws_route_table_association" "POC_Private2" {
  subnet_id      = aws_subnet.POC_Private_subnet_2.id
  route_table_id = aws_route_table.POC_Private_route_table.id
}

resource "aws_security_group" "POC_Security_Group_web_access" {
  name        = "POC_Security_Group_web_access"
  description = "Allow TLS inbound traffic"
  vpc_id = aws_subnet.POC_Public_subnet_1.vpc_id

  ingress {
    description = "Port 80 from VPC to connect application"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    description = "Port 22 from VPC to connect instance"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "POC_Security_Group_web_access"
  }
}

resource "aws_instance" "instance" {
  ami             = "ami-02396cdd13e9a1257"
  instance_type   = "t2.micro"
  key_name        = "POC_terraform"
  vpc_security_group_ids = [aws_security_group.POC_Security_Group_web_access.id]
  subnet_id       = aws_subnet.POC_Public_subnet_1.id
  tags = {
    Name = "POC_Web server by TerraForm"
  }
}
output "my-public-ip" {
  value = aws_instance.instance.public_ip
}






