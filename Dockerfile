FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
#ENV REFLEX_HOME=/opt/esoreflex

# Instalación de dependencias necesarias
RUN apt-get update && apt-get install -y \
    openjdk-11-jre \
    python3 python3-pip \
    python3-numpy python3-astropy python3-matplotlib \
    python3-wxgtk4.0 \
    g++ make pkg-config zlib1g-dev gzip tar wget curl unzip \
    libxrender1 libxtst6 libxi6 x11-apps \
	gedit nemo dbus-x11 \
    yorick yorick-yeti yorick-optimpack \
	libcurl4-openssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Crear directorios útiles
#RUN mkdir -p ${REFLEX_HOME}

# Crea un usuario no-root
#RUN useradd -ms /bin/bash reflexuser
#USER reflexuser

# Directorio de trabajo por defecto
WORKDIR /home

# Copia tu script de instalación o lo descarga, luego ejecútalo (adaptar si necesario)
ENV REFLEX_INSTALLER_URL="https://www.eso.org/sci/software/pipelines/install_esoreflex"
RUN wget $REFLEX_INSTALLER_URL -O installer.sh && \
     chmod +x installer.sh
#     ./installer.sh -q -dir /home && \
#     rm installer.sh

#Creamos alias para ejecutar esoreflex mas facil
RUN echo "alias esoreflex='/home/install/bin/./esoreflex'" >> /root/.bashrc


CMD ["/bin/bash"]

