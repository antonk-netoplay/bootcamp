provider "aws" {
    region = "eu-west-1"
}
resource "aws_instance" "test-instance" {
    ami                     = "ami-0d64bb532e0502c46"
    instance_type           = "t2.micro"
    vpc_security_group_ids  = [aws_security_group.instance.id]
    user_data = <<-EOF
              #!/bin/bash
              cat <<HTML > index.html
              <!DOCTYPE html>
              <html lang="en">
              <head>
                  <meta charset="UTF-8">
                  <meta name="viewport" content="width=device-width, initial-scale=1.0">
                  <title>special site</title>
                  <style>
                      body {
                          font-family: Arial, sans-serif;
                          background-color: #f0f8ff; /* Light blue background */
                          color: #333; /* Dark gray text */
                          margin: 0;
                          padding: 0;
                          display: flex;
                          justify-content: center;
                          align-items: center;
                          height: 100vh; /* Full height viewport */
                      }
                      h1 {
                          color: #ff4500; /* Bright orange */
                          text-shadow: 2px 2px 5px rgba(0, 0, 0, 0.2); /* Subtle shadow */
                      }
                  </style>
              </head>
              <body>
                  <h1>Ya rodilsya! (c) Luntik!</h1>
              </body>
              </html>
              HTML
              nohup busybox httpd -f -p ${var.server_port} &
    EOF

    user_data_replace_on_change = true


    tags          = {
        Name      = "terraform-example"     
    }
}

resource "aws_security_group" "instance" {
    name = "terraform-example-instance"

    ingress {
        from_port   = var.server_port
        to_port     = var.server_port
        protocol    = "tcp"
        cidr_blocks  = ["0.0.0.0/0"]
    }
}

variable "server_port" {
    description = "The port the server will use for HTTP requests"
    type        = number
    default     = 8080
}

output "public_ip" {
    value          = aws_instance.test-instance.public_ip
    description    = "The public IP address of the web server" 
}

