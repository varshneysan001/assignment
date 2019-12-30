provider "aws" {
	region = "${var.vpc_region}"
	access_key = "${var.aws_access_key}"
  	secret_key = "${var.aws_secret_key}"
}

resource "aws_vpc" "vpc" {
  	cidr_block           = "${var.vpc_cidr_block}"
  	enable_dns_hostnames = true
  	enable_dns_support   = true
	tags = {
		Name = "DevVPC"
	}
}
resource "aws_subnet" "private-1a" {
  	vpc_id                  = "${aws_vpc.vpc.id}"
  	availability_zone       = "${var.private_subnet_1a_az}"
  	cidr_block              = "${var.private_subnet_cidr_block_1a}"
  	map_public_ip_on_launch = false
}

resource "aws_subnet" "public-1a" {
 	vpc_id                  = "${aws_vpc.vpc.id}"
  	availability_zone       = "${var.public_subnet_1a_az}"
  	cidr_block              = "${var.public_subnet_1a_cidr_block}"
  	map_public_ip_on_launch = false
}

resource "aws_internet_gateway" "ig" {
	vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_route_table" "public-1a" {
	vpc_id = "${aws_vpc.vpc.id}"
	route {
      cidr_block = "0.0.0.0/0"
	  gateway_id = "${aws_internet_gateway.ig.id}"
	}
}

resource "aws_route_table_association" "table_association" {
	subnet_id = "${aws_subnet.public-1a.id}"
	route_table_id = "${aws_route_table.public-1a.id}"	
}

resource "aws_route_table" "private-1a" {
	vpc_id = "${aws_vpc.vpc.id}"
	route {
		cidr_block = "0.0.0.0/0"
		nat_gateway_id   = "${aws_nat_gateway.ngw-1a.id}"	
	}
	depends_on = ["aws_nat_gateway.ngw-1a"]
}

resource "aws_route_table_association" "table_association-private" {
	subnet_id = "${aws_subnet.private-1a.id}"
	route_table_id = "${aws_route_table.private-1a.id}"	
}

resource "aws_eip" "nat-1a" {
  	vpc = true
}

resource "aws_nat_gateway" "ngw-1a" {
  	allocation_id = "${aws_eip.nat-1a.id}"
  	subnet_id     = "${aws_subnet.public-1a.id}"
  	depends_on    = ["aws_internet_gateway.ig"]
}

resource "aws_security_group" "public_sg" {
	name        = "Dev-public-SG"
	description = "SSH and http for public hosts"
	vpc_id      = "${aws_vpc.vpc.id}"
	ingress {
      	from_port = 22
      	to_port = 22
      	protocol = "tcp"
      	cidr_blocks = ["0.0.0.0/0"]
  	}
  	ingress {
      	from_port = 80
      	to_port = 80
      	protocol = "tcp"
      	cidr_blocks = ["0.0.0.0/0"]
  	}
	ingress {
      	from_port = 8080
      	to_port = 8080
      	protocol = "tcp"
      	cidr_blocks = ["0.0.0.0/0"]
  	}  
	egress {
    	from_port       = 0
    	to_port         = 0
    	protocol        = "-1"
    	cidr_blocks     = ["0.0.0.0/0"]
  	} 	
}  

resource "aws_security_group" "private_sg" {
	name        = "Dev-private-SG"
	description = "SSH private hosts only"
	vpc_id      = "${aws_vpc.vpc.id}"
	ingress {
		from_port         = 22
  		to_port           = 22
  		protocol          = "tcp"
  		security_groups   = ["${aws_security_group.public_sg.id}"]	
	}
	egress {
    	from_port = 80
    	to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

}

resource "aws_instance" "public_ec2" {
	ami				= "${var.aws_ami}"
	instance_type	= "t2.micro"
	count			= 1
	private_ip 		= "172.20.10.20"
	subnet_id		= "${aws_subnet.public-1a.id}"
	vpc_security_group_ids = ["${aws_security_group.public_sg.id}"]
	key_name		= "${var.key_name}"
	user_data		= "${file("instance_setup_server.sh")}"
	tags {
		Name = "Jenkins Server"
	}
}

resource "aws_eip" "web" {
	vpc = true
	instance        = "${aws_instance.public_ec2.id}"
	associate_with_private_ip =  "${aws_instance.public_ec2.private_ip}"
	depends_on                = ["aws_internet_gateway.ig"]
}

output "instance_public_ip_addr" {
  value = ["${aws_eip.web.public_ip}"]
}

resource "aws_instance" "private_ec2" {
	ami				= "${var.aws_ami}"
	instance_type	= "t2.micro"
	count			= 1
	subnet_id		= "${aws_subnet.private-1a.id}"
	vpc_security_group_ids = ["${aws_security_group.private_sg.id}"]
	key_name		= "${var.key_name}"
	user_data		= "${file("instance_setup_client.sh")}"
	tags {
		Name = "DevServer"
	}
	depends_on = ["aws_security_group.private_sg"]
}

output "instance_private_ip_addr" {
  value = ["${aws_instance.private_ec2.private_ip}"]
}
