#!/bin/bash

#./script.sh                         # usa esoreflex-eris como nombre original y para --name
#./script.sh contenedor-original     # usa ese nombre para original y para --name
#./script.sh contenedor-original nuevo-nombre --save # # Crea contenedor e imagen nueva
#./script.sh --root                  # como root, con esoreflex-eris
#./script.sh --root contenedor-original nuevo-nombre  --save# root con nombres personalizados

# Variables por defecto
DEFAULT_CONTAINER_NAME="esoreflex-eris"
USE_ROOT=false
SAVE_IMAGE=false
# Procesar argumentos:
# Si el primer argumento es --root, activamos uso root y shift para que lo siguiente sea el nombre original
if [[ "$1" == "--root" ]]; then
  USE_ROOT=true
  shift
fi

# Primer argumento: nombre original del contenedor, o defecto
ORIGINAL_NAME=${1:-$DEFAULT_CONTAINER_NAME}

# Segundo argumento: nuevo nombre para --name, o el mismo original si no se da
NEW_NAME=${2:-$ORIGINAL_NAME}

# Ver si se pasa el flag --save
for arg in "$@"; do
  if [[ "$arg" == "--save" ]]; then
    SAVE_IMAGE=true
  fi
done

# Define DISPLAY variable
export DISPLAY=$(grep nameserver /etc/resolv.conf | awk '{print $2}'):0

if [ "$USE_ROOT" = true ]; then
  echo "Habilitando acceso X11 para root..."
  xhost +local:root
else
  echo "Habilitando acceso X11 para el usuario actual: $USER"
  xhost +SI:localuser:$USER
fi

echo "Iniciando el contenedor Docker '$ORIGINAL_NAME' con nombre '$NEW_NAME'"

if [ "$USE_ROOT" = true ]; then
  docker run -it \
    --name "$NEW_NAME" \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v ~/esoreflex_data:/data \
    "$ORIGINAL_NAME"
else
  docker run -it \
    --name "$NEW_NAME" \
    -u $(id -u):$(id -g) \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v ~/esoreflex_data:/data \
    "$ORIGINAL_NAME"
fi


EXIT_CODE=$?
echo "$EXIT_CODE"
echo "$SAVE_IMAGE" 
# Guardar como nueva imagen si se pidió
if [ "$SAVE_IMAGE" = true ] && [ "$EXIT_CODE" -eq 0 ]; then
  echo "Guardando contenedor '$NEW_NAME' como imagen '$NEW_NAME:latest'"
  docker commit "$NEW_NAME" "$NEW_NAME:latest"
  echo "Imagen '$NEW_NAME:latest' creada."
fi
