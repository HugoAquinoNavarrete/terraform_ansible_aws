# Integración de Terraform con Ansible para la ejecución de Playbooks aplicados a un inventario dinámico

Script en Terraform que automatiza el despliegue en AWS n instancias EC2 tipo ubuntu con acceso a internet que permiten tráfico SSH, HTTP y HTTPS con el cual a través de un archivo se puede integrar con Ansible para ejecutar Playbooks

## 1. Configura AWS (este script corre en la región "us-west-2")
Antes de ejecutar este script, ejecuta `aws configure` para habilitar
   - AWS Access Key ID
   - AWS Secret Access Key
   - Default region name 
   - Default output format (json,yaml,yaml-stream,text,table)

## 2. El script generará la llave privada
El archivo se llamará `key`

## 3. Conexión por SSH a la máquina virtual 
   ```bash
   ssh -v -l ubuntu -i key <ip_publica_instancia_ec2>
   ```

## 4. Script compatible con la versión de Terraform v0.13.5, estos son los pasos para descargarlo e instalarlo
   ```bash
  wget https://releases.hashicorp.com/terraform/0.13.5/terraform_0.13.5_linux_amd64.zip
  unzip terraform_0.13.5_linux_amd64.zip
  sudo mv terraform /usr/local/bin/
  terraform --version 
   ```

## 5. Si es la primera vez que corres el script, ejecuta `terraform init`

## 6. Para ejecutar el script `terraform apply -var "nombre_instancia=<nombre_recursos>" -var "cantidad_instancias=<n>" -var "subred=<subred>"` cuando el siguiente mensaje aparezca, escribe `yes`:
   ```bash
   Do you want to perform these actions?
     Terraform will perform the actions described above.
     Only 'yes' will be accepted to approve.

     Enter a value:
   ```

Una vez el script se ejecuta generará un mensaje parecido a esto:

   ```bash
   Apply complete! Resources: <cantidad_recursos> added, 0 changed, 0 destroyed.
   ```

## 7. Una vez ejecutado el script, se creará un archivo que contiene el inventario `ansible_inventario.txt`, ve su contenido usando el comando `cat ansible_inventario.txt`

## 8. Ejecutemos un Playbook para establecer un `ping` de la siguiente manera `ansible-playbook -i ansible_inventario.txt playbooks/ping.yml --private-key=key`. La ejecución se hará tantas veces como líneas existan en el archivo del inventario, a la pregunta `Are you sure you want to continue connecting (yes/no/[fingerprint])?:` contesta `yes` una vez aparezca `ok` teclea `Control-C` para volver a ejecutar el script a fin de que se haga el mismo proceso para el siguiente equipo (la siguiente salida es de la ejecución para un solo equipo)
   ```bash
   PLAY [servers] ************************************************************************************************************************

   TASK [ping] ***************************************************************************************************************************
   The authenticity of host 'ip_instancia_creada (ip_instancia_creada)' can't be established.
   ECDSA key fingerprint is SHA256:XXXXXXX.
   Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
   ok: [ec2-ip-instancia-creada.region.compute.amazonaws.com]

   PLAY RECAP ****************************************************************************************************************************
   ec2-ip-instancia-creada.region.compute.amazonaws.com : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
   ```

## 9. Ejecutemos un Playbook para instalar `Docker` y `Python` en la lista de equipos que tenemos del inventario `ansible-playbook -i ansible_inventario.txt playbooks/docker_python_instalacion.yml --private-key=key`. En pantalla se irá mostrando el avance de la instalación de los componentes (la siguiente salida es de la ejecución para un solo equipo)
   ```bash
   PLAY [Instalar Docker] ******************************************************************************************************************************************************************

   TASK [Gathering Facts] ******************************************************************************************************************************************************************
   ok: [ec2-ip-instance-created.region.compute.amazonaws.com]

   TASK [Actualizar paquetes apt] **********************************************************************************************************************************************************
   changed: [ec2-ip-instance-created.region.compute.amazonaws.com]

   TASK [Instalar paquetes para Docker] ****************************************************************************************************************************************************
   changed: [ec2-ip-instance-created.region.compute.amazonaws.com]

   TASK [Agrega Docker GPG apt Key] ********************************************************************************************************************************************************
   changed: [ec2-ip-instance-created.region.compute.amazonaws.com]

   TASK [Salva el release de Ubuntu en una variable] ***************************************************************************************************************************************
   changed: [ec2-ip-instance-created.region.compute.amazonaws.com]

   TASK [Agrega el repositorio Docker] *****************************************************************************************************************************************************
   changed: [ec2-ip-instance-created.region.compute.amazonaws.com]

   TASK [Actualiza los paquetes apt] *******************************************************************************************************************************************************
   changed: [ec2-ip-instance-created.region.compute.amazonaws.com]

   TASK [Instala Docker] *******************************************************************************************************************************************************************
   changed: [ec2-ip-instance-created.region.compute.amazonaws.com]

   TASK [Prueba Docker con el contenedor hello world] **************************************************************************************************************************************
   changed: [ec2-ip-instance-created.region.compute.amazonaws.com]

   TASK [Muestra la salida del contenedor hello world] *************************************************************************************************************************************
   ok: [ec2-ip-instance-created.region.compute.amazonaws.com] => {
    "msg": "Container Output: \nHello from Docker!\nThis message shows that your installation appears to be working correctly.\n\nTo generate this message, Docker took the following ste
ps:\n 1. The Docker client contacted the Docker daemon.\n 2. The Docker daemon pulled the \"hello-world\" image from the Docker Hub.\n    (amd64)\n 3. The Docker daemon created a new co
ntainer from that image which runs the\n    executable that produces the output you are currently reading.\n 4. The Docker daemon streamed that output to the Docker client, which sent i
t\n    to your terminal.\n\nTo try something more ambitious, you can run an Ubuntu container with:\n $ docker run -it ubuntu bash\n\nShare images, automate workflows, and more with a fr
ee Docker ID:\n https://hub.docker.com/\n\nFor more examples and ideas, visit:\n https://docs.docker.com/get-started/"
}

   TASK [Create el grupo docker] ***********************************************************************************************************************************************************
   ok: [ec2-ip-instance-created.region.compute.amazonaws.com]

   TASK [Agrega el usuario ubuntu al grupo docker] *****************************************************************************************************************************************
   changed: [ec2-ip-instance-created.region.compute.amazonaws.com]

   TASK [Instala Docker Compose] ***********************************************************************************************************************************************************
   changed: [ec2-ip-instance-created.region.compute.amazonaws.com]

   TASK [Instala Ctop] *********************************************************************************************************************************************************************
   changed: [ec2-ip-instance-created.region.compute.amazonaws.com]

   TASK [Instala Python] *******************************************************************************************************************************************************************
   ok: [ec2-ip-instance-created.region.compute.amazonaws.com]

   TASK [Instala pip3] *********************************************************************************************************************************************************************
   changed: [ec2-ip-instance-created.region.compute.amazonaws.com]

   TASK [Instala módulo Docker para Python] ************************************************************************************************************************************************
   changed: [ec2-ip-instance-created.region.compute.amazonaws.com]

   TASK [Reinicia la VM para que los cambios surgan efecto] ********************************************************************************************************************************
   changed: [ec2-ip-instance-created.region.compute.amazonaws.com]

   PLAY RECAP ******************************************************************************************************************************************************************************
   ec2-ip-instance-created.region.compute.amazonaws.com : ok=18   changed=14   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
   ```

## 10. Para eliminar la infraestructura desplegada, ejecuta `terraform destroy` y cuando aparezca el siguiente mensaje, escribe `yes`:
   ```bash
   Do you really want to destroy?
     Terraform will destroy all your managed infrastructure, as shown above.
     There is no undo. Only 'yes' will be accepted to confirm.

     Enter a value:
   ```

El script una vez ejecutado generará un mensaje parecido a esto:

   ```bash
   Destroy complete! Resources: <cantidad_recursos> destroyed.
   ```

## 11. Valida en el portal de AWS que los recursos se hayan eliminado
Las instancias EC2 deberan aparecen con estado `Terminated` y después de algunos minutos desaparecerán de la consola
