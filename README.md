# Esoreflex-docker
Scripts que instalan Esoreflex en un docker usando el script de la ESO. Esto permite instalar esoreflex de manera aislada del sistema operativo del pc.

## Requisitos para wsl-ubuntu desde windows 10 y ubuntu nativo (omitir para Windows 11)

Para wsl-ubuntu desde windows, se debe instalar [Xming](http://www.straightrunning.com/XmingNotes/) en windows para acceder a la GUI de aplicaciones que corren en wsl-ubuntu. Para poder permitir la conexion con wsl-ubuntu de manera simple se sugiere abilitar la opción ''Disable access control'' en Xlaunch. Sólo abilitar esta opcion si estamos ok con los riesgos de seguiridad (comom todo corre en el mismo pc no hay problema).

## Instalación de Docker  
Docker es necesario para crear los contenedores en donde se instalará esoreflex. 
Para instalar Docker Desktop en Windows y usarlo via wsl, usar este [link](https://docs.docker.com/desktop/setup/install/windows-install/).
Para instalar Docker en Ubuntu(o Pop_os!), seguir los pasos en este [link](https://docs.docker.com/engine/install/ubuntu/)

En el caso de wsl, Docker Desktop debe estar configurado para integrarse con wsl. Para verificar esto, En Docker Desktop ir a Settings → Resources → WSL Integration.

Es importante tener conexión a internet para todo el proceso de instalación.

## Creando el contenedor con Esoreflex

El contenedor que alojará Esoreflex usa una imagen de ubuntu 22.04. La instalación de Esoreflex utiliza el [script](https://www.eso.org/sci/software/pipelines/install_esoreflex) provisto en la página de la ESO.  

Para crear el contenedor, primero creamos una carpeta en donde descargamos el archivo **Dockerfile**. Dentro de esta carpeta abrimos una terminal y ejecutamos el comando `docker build -t esoreflex-base .`. después de uno minutos, se creará el contenedor llamado esoreflex-base. Este contenedor contiene el sistema operativo (Ubuntu 22.04) en donde instalaremos Esoreflex.

### Instalar Esoreflex en el contenedor "esoreflex-base"

El siguiente paso es instalar Esoreflex en esoreflex-base. Para ello, primero hacemos ejecutable el script run_esoreflex_image.sh desde wsl-ubuntu con el comando `chmod +x run_esoreflex_image.sh` (o `chmod +x run_esoreflex_image_w11.sh` para Windows 11). Luego,
ejecutamos `./run_esoreflex_image.sh --root --save esoreflex-base image_name` ( o `./run_esoreflex_image_w11.sh --root --save esoreflex-base image_name`) desde wsl-ubuntu para entrar en modo interactivo y poder hacer uso de la terminal en esoreflex-base. `--root` permite acceder en modo root (ya que el dockerfile crea el contenedor en modo root), mientras que `image_name` es el nombre de la imagen creada a partir de esoreflex-base. Como ejemplo, en caso de instalar sólo la pipeline de ERIS, `image_name` podria ser "esoreflex-eris".

Una vez dentro del contenedor, ejecutamos `./installer.sh`, y seguimos los pasos del instalador de Esoreflex. Completado el proceso, ya tendremos instalado Esoreflex con la(s) pipelines requeridas en la imagen "image_name".

Para ejecutar Esoreflex dentro de `image_name` se debe correr el comando `/home/install/bin/./esoreflex`. Para no repetir esta linea de comando cada vez que se quiera usar Esoreflex, se puede crear un alias, i.e., `echo "alias esoreflex='/home/install/bin/./esoreflex'" >> /root/.bashrc && source /root/.bashrc`. De esta manera, escribiendo `esoreflex` desde la terminal de `image_name` se puede correr Esoreflex inmediatamente.

### Revisar lista de pipelines instaladas.

Para ver las pipelines disponibles usar el comando `esoreflex -l`. para correr esoreflex con una pipeline especifica (e.g., sphere_irdis_ci_dbi_dpi ), usar el comando `esoreflex sphere_irdis_ci_dbi_dpi`

## Ejecutar imagen con Esoreflex

Si estamos trabajando por primera vez con la imagen desde otra máquina. primero debemos cargarla al docker local con el comando `docker load -i <image_name>.tar` (recordar poner la extension de la imagen y el path completo en caso de ejecutar el comando fuera de la carpeta que aloja la imagen).

Luego, para ejecutar la imagen, nos vamos a la carpeta en donde se encuentra el archivo run_esoreflex_image.sh, abrimos una terminal y ejecutamos `./run_esoreflex_image.sh --root <image_name>` (`./run_esoreflex_image_w11.sh --root <image_name>`), con "image_name" el nombre de la imagen. Para ver el listado de imagenes disponibles, ejecutamos el comando `docker images`. Si quieremos correr la imagen guardando cualquier cambios hecho, debemos ejecutar el archivo .sh con la opcion `--save`, i.e.,  `./run_esoreflex_image.sh --root --save <image_name>  <new_image_name>` (`./run_esoreflex_image_w11.sh --root --save <image_name>  <new_image_name>`).

## Montar carpeta o disco externo en la imagen.

Antes de correr la imagen, montar en wsl-ubuntu (o ubuntu nativo) la carpeta o disco externo con el comando `sudo mount -t drvfs E: /mnt/e` (en este caso es el disco externo E). Con la carpeta/disco montada procedemos a montarla en la imagen. Para esto, al momento de ejecutar `./run_esoreflex_image.sh` (`./run_esoreflex_image_w11.sh`) agregamos el input `--external /mnt/e`.

## Guardar la imagen

Para guardar la imagen y usarla en otro pc se debe ejecutar `docker save -o esoreflex-sphere.tar esoreflex-sphere:latest`. Esto crea un archivo llamado esoreflex-sphere.tar con toda la imagen. Se puede cambiar el nombre "esoreflex-sphere" y el tag (:latest) si hay otra etiqueta.


## Comandos de Docker útiles 

### Contenedores
| Comando                                  | Descripción                                      |
|------------------------------------------|--------------------------------------------------|
| docker run -it <imagen>                  | Ejecuta un contenedor de forma interactiva       |
| docker ps                                | Lista contenedores activos                       |
| docker ps -a                             | Lista todos los contenedores                     |
| docker start <contenedor>                | Inicia un contenedor detenido                    |
| docker stop <contenedor>                 | Detiene un contenedor activo                     |
| docker restart <contenedor>              | Reinicia un contenedor                           |
| docker exec -it <contenedor> bash        | Entra a un contenedor con bash                   |
| docker attach <contenedor>               | Se conecta a la terminal activa del contenedor   |
| docker rm <contenedor>                   | Elimina un contenedor detenido                   |
| docker rm -f <contenedor>                | Fuerza la eliminación incluso si está en uso     |
| docker logs <contenedor>                 | Muestra el log del contenedor                    |
| docker inspect <contenedor>              | Muestra detalles del contenedor                  |
| docker rename <viejo> <nuevo>            | Renombra un contenedor                           |
| docker cp <cont:archivo> <destino>       | Copia archivos entre contenedor y host           |


### Imagenes
| Comando                                  | Descripción                                      |
|------------------------------------------|--------------------------------------------------|
| docker images                            | Lista todas las imágenes locales                 |
| docker build -t nombre:tag .             | Crea una imagen desde un Dockerfile              |
| docker pull <imagen>                     | Descarga una imagen del Docker Hub               |
| docker push <imagen>                     | Sube una imagen al Docker Hub                    |
| docker tag <img> <nuevo:tag>             | Renombra o reetiqueta una imagen                 |
| docker rmi <imagen>                      | Elimina una imagen                               |
| docker save -o imagen.tar <imagen>       | Exporta una imagen a un archivo `.tar`           |
| docker load -i imagen.tar                | Importa una imagen desde un archivo `.tar`       |
| docker history <imagen>                  | Muestra el historial de capas de la imagen       |
| docker commit <contenedor> <nueva_img>   | Guarda cambios del contenedor como nueva imagen  |



### Limpieza y mantenimiento

| Comando                                  | Descripción                                      |
|------------------------------------------|--------------------------------------------------|
| docker system prune                      | Limpia todo lo no utilizado                      |
| docker image prune                       | Elimina imágenes sin etiqueta `<none>`           |
| docker volume prune                      | Elimina volúmenes no utilizados                  |
| docker container prune                   | Elimina contenedores detenidos                   |


