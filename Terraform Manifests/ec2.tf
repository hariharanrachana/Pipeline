# create 3 ec2 instances 
resource "aws_instance" "tf-ec2" {
    for_each = var.instances_configs
    ami= each.value.amiid
    instance_type = each.value.instance_type
    key_name = each.value.key_name
    subnet_id = aws_subnet.tf_public_subnet_1.id
    vpc_security_group_ids = [aws_security_group.tf_sg_new.id]
    associate_public_ip_address = true 
    tags = {
        "Name" = "${each.key}"
    }
    connection {
        type = "ssh"
        user = "ubuntu"
        host = self.public_ip
        private_key = file("project-key.pem")
    }
    provisioner "file" {
        source = each.key == "ansible" ? "ansible.sh" : "empty.sh"
        destination = each.key == "ansible" ? "/home/ubuntu/ansible.sh" : "empty.sh"
    }
    provisioner "remote-exec" {
        inline = [ 
            each.key == "ansible" ? "chmod +x /home/ubuntu/ansible.sh && sh /home/ubuntu/ansible.sh" : "echo 'skipped'"
         ]
    }
    provisioner "file" {
    source = "project-key.pem"
    destination = "/home/ubuntu/project-key.pem"
    }

}