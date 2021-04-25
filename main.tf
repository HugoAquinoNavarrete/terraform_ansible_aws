# Script en Terraform para desplegar en AWS n instancias EC2 tipo ubuntu 
# con acceso a internet que permiten tráfico SSH, HTTP y HTTPS
# que logra integrarse con Ansible al generar un archivo dinámico de inventario
# Hugo Aquino
# Abril 2021

# Antes de ejecutar este script, ejecuta "aws configure" para poder habilitar
# AWS Access Key ID
# AWS Secret Access Key
# Default region name
# Default output format (YAML)

# Después genera una llave ejecutando
# "ssh-keygen"
# La llave se llama key.pub. Sálvalas en el directorio donde este este script <ruta_completa>/key
# Deja en blanco "passphrase"

# Para conectarte con la VM una vez creada
# ssh -v -l ubuntu -i key <ip_publica_instancia_creada> 

# Para correr este script desde la consola:
# terraform apply -var "nombre_instancia=<nombre_recursos>" -var "cantidad_instancias=<n>"

# Para ajustar la cantidad de VMs a crear hay que cambiar el valor de la siguiente variable a la cantidad "default = n"

# Variable para saber cuantas instancias crear
variable cantidad_instancias {
  default = 1
}

# Para ajustar el nombre de los recursos hay que cambiar el valor de la siguiente variable al nombre que desees "default = <nombre>"

variable nombre_instancia {
  default = "prueba"
}

# Haremos despliegue en AWS
provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

# Generemos una llave
resource "aws_key_pair" "key" {
  key_name   = "key"
  public_key = file("key.pub")
}

# Crea la VPC
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.1.0/24"
  enable_dns_hostnames = true
  enable_dns_support   = true
 
  tags = {
    Name = "${var.nombre_instancia}-vpc"
  }
}

# Crea un gateway de Internet
resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = aws_vpc.vpc.id
 
  tags = {
    Name = "${var.nombre_instancia}-internet-gateway"
  }
}

# Crea las subredes internas
resource "aws_subnet" "subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "${var.nombre_instancia}-subnet"
  }
}

# Tabla de ruteo para internet
resource "aws_route_table" "route-table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gateway.id
  }

  tags = {
    Name = "${var.nombre_instancia}-tabla-ruteo-acceso-internet"
  }
}

# Asocia la tabla de ruteo a la subred
resource "aws_route_table_association" "subnet-asociacion" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.route-table.id
}

# Crea el grupo de seguridad
resource "aws_security_group" "security-group" {
  name        = "${var.nombre_instancia}-security-group" 
  description = "Permite trafico entrante"
  vpc_id      = aws_vpc.vpc.id

  # Permite trafico SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Permite trafico HTTP
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permite trafico HTTPS
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permite acceso a Internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.nombre_instancia}-security-group"
  }
}

# Crea n instancias Ubuntu
resource "aws_instance" "aws" {
  count                       = var.cantidad_instancias
  ami                         = "ami-0a8c16ff18611b4f7" #para una imagen nueva ami-0d1cd67c26f5fca19 para jenkins ami-0a8c16ff18611b4f7
  instance_type               = "t2.medium" #para pruebas t2.micro, para labs jenkins t2.medium
  key_name                    = aws_key_pair.key.key_name
  vpc_security_group_ids      = [aws_security_group.security-group.id]
  subnet_id                   = aws_subnet.subnet.id
  associate_public_ip_address = "true"

  root_block_device {
    volume_size           = "20" #para pruebas 10, para labs jenkins 20
    volume_type           = "standard"
    delete_on_termination = "true"
  }

  tags = {
    Name = "${var.nombre_instancia}-${count.index + 1}"
  }

}
