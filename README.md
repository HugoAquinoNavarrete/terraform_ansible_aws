# Integración de Terraform con Ansible para la ejecución de Playbooks aplicados a un inventario dinámico

Script en Terraform que automatiza el despliegue en AWS n instancias EC2 tipo ubuntu con acceso a internet que permiten tráfico SSH, HTTP y HTTPS con el cual a través de un archivo se puede integrar con Ansible para ejecutar Playbooks

## 1. Configura AWS (este script corre en la región "us-west-2")
Antes de ejecutar este script, ejecuta `aws configure` para habilitar
   - AWS Access Key ID
   - AWS Secret Access Key
   - Default region name 
   - Default output format (json,yaml,yaml-stream,text,table)

## 2. Genera un par de llaves rsa pública/privada
   ```bash 
   ssh-keygen
   ```

   Sálvala en el directorio donde correras este script `<ruta_absoluta>/key`, deja vacío `passphrase`. La llave debe llamarse `key.pub`, sálvala en el directorio donde correras este script `<ruta_absoluta>/key`, deja vacío `passphrase`

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

## 6. Para ejecutar el script `terraform apply -var "nombre_instancia=<nombre_recursos>" -var "cantidad_instancias=<n>"` cuando el siguiente mensaje aparezca, escribe `yes`:
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

## 8. Ejecutemos un Playbook para establecer un `ping` de la siguiente manera `ansible-playbook -i ansible_inventario.txt playbooks/ping.yml --private-key=key`. La ejecución se hará tantas veces como líneas existan en el archivo del inventario, a la pregunta `Are you sure you want to continue connecting (yes/no/[fingerprint])?:` contesta `yes` una vez aparezca `ok` teclea `Control-C` para volver a ejecutar el script a fin de que se haga el mismo proceso para el siguiente equipo.
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

## 9. Ejecutemos un Playbook para instalar `Docker` y `Python` en la lista de equipos que tenemos del inventario `ansible-playbook -i ansible_inventario.txt playbooks/docker_python_instalacion.yml ubuntu@u --private-key=key`. En pantalla se irá mostrando el avance de la instalación de los componentes.

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
