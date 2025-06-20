README update
# Esoreflex-docker
Scripts que instalan Esoreflex en un docker usando el script de la ESO. Esto permite instalar esoreflex de manera aislada del sistema operativo del pc.

## Requisitos (para wsl-ubuntu desde windows y ubuntu nativo)

Para wsl-ubuntu desde windows, se debe instalar [Xming](http://www.straightrunning.com/XmingNotes/) en windows para acceder a la GUI de aplicaciones que corren en wsl-ubuntu. Para poder permitir la conexion con wsl-ubuntu de manera simple se sugiere abilitar la opción ''Disable access control'' en Xlaunch. Sólo abilitar esta opcion si estamos ok con los riesgos de seguiridad (comom todo corre en el mismo pc no hay problema).

Docker es tambien necesario para crear los contenedores en donde se instalará esoreflex. 
Para instalar Docker Desktop en Windows y usarlo via wsl, usar este [link](https://docs.docker.com/desktop/setup/install/windows-install/).
Para instalar Docker en Ubuntu(o Pop_os!), seguir los pasos en este [link](https://docs.docker.com/engine/install/ubuntu/)

En el caso de wsl, Docker Desktop debe estar configurado para integrarse con wsl. Para verificar esto, En Docker Desktop ir a Settings → Resources → WSL Integration


## Creando el contenedor con Esoreflex

El contenedor que alojará Esoreflex usa una imagen de ubuntu 22.04. La instalación de Esoreflex utiliza el [script](https://www.eso.org/sci/software/pipelines/install_esoreflex) provisto en la página de la ESO.  

Para crear el contenedor, primero creamos una carpeta en donde descargamos el archivo **Dockerfile**. Dentro de esta carpeta abrimos una terminal y ejecutamos el comando `docker build -t esoreflex-base .`. después de uno minutos, se creará el contenedor llamado esoreflex-base. Este contenedor contiene el sistema operativo (Ubuntu 22.04) en donde instalaremos Esoreflex.

### Instalar Esoreflex en el contenedor "esoreflex-base"

El siguiente paso es instalar Esoreflex en esoreflex-base. Para ello, primero ejecutamos el script `./run_esoreflex_container.sh --root esoreflex-base image_name` desde wsl-ubuntu para entrar en modo interactivo y poder hacer uso de la terminal en esoreflex-base. `--root` permite acceder en modo root (ya que el dockerfile crea el contenedor en modo root), mientras que `image_name` es el nombre de la imagen creada a partir de esoreflex-base. Como ejemplo, en caso de instalar sólo la pipeline de ERIS, `image_name` podria ser "esoreflex-eris".

Una vez dentro del contenedor, ejecutamos `./installer.sh`, y seguimos los pasos del instalador de Esoreflex. Completado el proceso, ya tendremos instalado Esoreflex con la(s) pipelines requeridas en la imagen "image_name".

Para ejecutar Esoreflex dentro de `image_name` se debe correr el comando `/home/install/bin/./esoreflex`. Para no repetir esta linea de comando cada vez que se quiera usar Esoreflex, se puede crear un alias, i.e., `echo "alias esoreflex='/home/install/bin/./esoreflex'" >> ~/.bashrc && source ~/.bashrc`. De esta manera, escribiendo `esoreflex` desde la terminal de `image_name` se puede correr Esoreflex inmediatamente.

### Revisar lista de pipelines instaladas.

Para ver las pipelines disponibles usar el comando `esoreflex -l`. para correr esoreflex con una pipeline especifica (e.g., sphere_irdis_ci_dbi_dpi ), usar el comando `esoreflex sphere_irdis_ci_dbi_dpi`









