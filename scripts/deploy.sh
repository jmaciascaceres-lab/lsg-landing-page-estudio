#!/usr/bin/env bash
# Deploy manual de la landing lsg-estudio.
# Correr EN la VM, parado en cualquier lado (usa rutas absolutas).
#
# Uso:
#   bash scripts/deploy.sh
#
# Qué hace:
#   1. git pull en el checkout del repo
#   2. copia index.html al directorio que sirve nginx
#   (nginx lee el archivo directo del disco en cada request vía `alias`,
#    no hace falta reload para cambios de contenido)

set -euo pipefail

REPO_DIR="$HOME/lsg-landing-page-estudio"
TARGET_DIR="/var/www/lsg-estudio"

echo "== git pull =="
cd "$REPO_DIR"
git pull origin main

echo "== copiando index.html =="
cp "$REPO_DIR/index.html" "$TARGET_DIR/index.html"

echo "== listo =="
echo "commit desplegado: $(git rev-parse --short HEAD)"
echo "verificar: curl -I https://lsg.diinf.usach.cl/lsg-estudio/"
