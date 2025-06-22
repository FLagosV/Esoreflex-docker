#!/bin/bash

# Variables por defecto
USE_ROOT=false
SAVE_CHANGES=false
EXTERNAL_PATH=""
IMAGE_NAME=""
NEW_TAG=""
CONTAINER_NAME=""

# Parseo de argumentos
while [[ $# -gt 0 ]]; do
  case "$1" in
    --root)
      USE_ROOT=true
      shift
      ;;
    --save)
      SAVE_CHANGES=true
      shift
      ;;
    --external)
      EXTERNAL_PATH="$2"
      shift 2
      ;;
    *)
      if [[ -z "$IMAGE_NAME" ]]; then
        IMAGE_NAME="$1"
      elif [[ -z "$NEW_TAG" ]]; then
        NEW_TAG="$1"
      fi
      shift
      ;;
  esac
done

# Validación básica
if [[ -z "$IMAGE_NAME" ]]; then
  echo "Uso: ./run_esoreflex_reduce.sh [--root] [--save] [--external /ruta/disco] <imagen> [nuevo_nombre]"
  exit 1
fi

if [[ -n "$EXTERNAL_PATH" && ! -d "$EXTERNAL_PATH" ]]; then
  echo "Ruta de disco externo no válida: $EXTERNAL_PATH"
  exit 1
fi

# Nombre temporal del contenedor
CONTAINER_NAME="tmp-${IMAGE_NAME//:/_}"

# Configurar DISPLAY para X11
export DISPLAY=$(grep nameserver /etc/resolv.conf | awk '{print $2}'):0

# Permitir acceso X11
if [ "$USE_ROOT" = true ]; then
  echo "Habilitando acceso X11 para root..."
  xhost +local:root
else
  echo "Habilitando acceso X11 para $USER..."
  xhost +SI:localuser:$USER
fi

# Construcción del comando docker run
DOCKER_CMD="docker run -it --name $CONTAINER_NAME \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix"

# Montar disco externo si se especificó
if [[ -n "$EXTERNAL_PATH" ]]; then
  DOCKER_CMD+=" -v $EXTERNAL_PATH:/mnt/disco"
fi

# Montar carpeta local (opcional, puedes comentar)
DOCKER_CMD+=" -v ~/esoreflex_data:/data"

# Modo root o usuario
if [ "$USE_ROOT" = true ]; then
  DOCKER_CMD+=" $IMAGE_NAME"
else
  DOCKER_CMD+=" -u $(id -u):$(id -g) $IMAGE_NAME"
fi

# Ejecutar contenedor
echo "Iniciando contenedor desde '$IMAGE_NAME' como '$CONTAINER_NAME'..."
eval $DOCKER_CMD

# Guardar imagen si se solicitó
if [ "$SAVE_CHANGES" = true ]; then
  if [[ -z "$NEW_TAG" ]]; then
    NEW_TAG="${IMAGE_NAME}-mod"
  fi

  echo "Guardando contenedor '$CONTAINER_NAME' como imagen '$NEW_TAG:latest'..."
  docker commit "$CONTAINER_NAME" "$NEW_TAG:latest"
  echo "Eliminando contenedor temporal..."
  docker rm "$CONTAINER_NAME"
else
  echo "ℹ️ No se guardaron cambios. El contenedor '$CONTAINER_NAME' permanece en Docker."
fi

