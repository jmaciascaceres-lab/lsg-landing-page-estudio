# Despliegue de `lsg-landing-page-estudio`

URL de producción: **https://lsg.diinf.usach.cl/lsg-estudio/**
(mismo host que `lsg-auth`, `lsg-core-api` y `lsg-status` — TLS ya resuelto vía
Let's Encrypt para este subdominio, no hace falta gestionar certificado nuevo).

Si prefieres la ruta corta `/estudio` en vez de `/lsg-estudio` (rompe la convención
`lsg-*` de los otros servicios pero es más natural para difusión), solo cambia el
`location` de nginx del paso 1 — el resto no cambia.

Mecanismo de deploy: **push-based vía GitHub Actions**. Cada push a `main` dispara
`rsync` hacia la VM de DIINF sobre SSH y recarga nginx. Requiere que la VM acepte
conexiones SSH entrantes desde los runners de GitHub Actions (rango de IPs dinámico,
no fijo — ver nota de firewall al final).

## 1. Bloque nginx en la VM

Se agrega al `server{}` existente de `lsg.diinf.usach.cl` — **no** crear un server
block nuevo, para no duplicar la config TLS ya en uso por los otros `lsg-*`.

```nginx
location = /lsg-estudio {
    return 301 /lsg-estudio/;
}

location /lsg-estudio/ {
    alias /var/www/lsg-estudio/;
    index index.html;
    try_files $uri $uri/ =404;
    add_header Cache-Control "public, max-age=300";
}
```

```bash
sudo mkdir -p /var/www/lsg-estudio
sudo chown -R jmacias:www-data /var/www/lsg-estudio
sudo nginx -t && sudo systemctl reload nginx
```

## 2. Usuario y llave SSH dedicados

No reutilices tu llave personal. Usa un usuario de servicio (o uno existente con
permisos acotados) y una llave exclusiva para este workflow.

Ya generé el par de llaves — quedan en los archivos adjuntos de este mensaje:

- `lsg_estudio_deploy_key` → **privada**, va al secret `DEPLOY_SSH_KEY` de GitHub.
  No la subas al repo ni la compartas por otro canal que no sea el secret manager de
  GitHub.
- `lsg_estudio_deploy_key.pub` → **pública**, va al `authorized_keys` del usuario de
  deploy en la VM:

  ```bash
  # en la VM de DIINF, como el usuario que hará el deploy:
  mkdir -p ~/.ssh && chmod 700 ~/.ssh
  echo "ssh-ed25519 AAAA...github-actions-lsg-estudio" >> ~/.ssh/authorized_keys
  chmod 600 ~/.ssh/authorized_keys
  ```

Dale a ese usuario permiso para escribir en `/var/www/lsg-estudio` y para recargar
nginx sin password:

```bash
# /etc/sudoers.d/lsg-estudio-deploy
jmacias ALL=(root) NOPASSWD: /usr/bin/systemctl reload nginx
```

## 3. Secrets del repo en GitHub

GitHub → repo `lsg-landing-page-estudio` → **Settings → Secrets and variables →
Actions → New repository secret**:

| Secret | Valor |
|---|---|
| `DEPLOY_HOST` | IP o hostname de la VM de DIINF (el mismo que resuelve `lsg.diinf.usach.cl`) |
| `DEPLOY_USER` | usuario SSH de deploy (paso 2) |
| `DEPLOY_SSH_KEY` | contenido completo de `lsg_estudio_deploy_key` (la privada, incluyendo las líneas `-----BEGIN...` / `-----END...`) |
| `DEPLOY_PATH` | `/var/www/lsg-estudio/` |

## 4. El workflow

Ya está en `.github/workflows/deploy.yml`. Se dispara en cada push a `main`, o
manualmente desde la pestaña **Actions** del repo (`workflow_dispatch`):

```yaml
on:
  push:
    branches: [main]
  workflow_dispatch: {}
```

Hace dos pasos: `rsync` del `index.html` hacia `DEPLOY_PATH`, y un `ssh` para
recargar nginx.

## 5. Nota importante de firewall/seguridad

Los runners de GitHub Actions **no tienen IPs fijas** — salen desde un rango dinámico
de Azure/GitHub que cambia constantemente. Si la VM de DIINF está detrás de un
firewall perimetral que solo permite IPs conocidas, este mecanismo **no va a
funcionar** tal cual: alguien tendría que abrir el puerto SSH a internet en general
(reduciendo la superficie de ataque de la VM) o usar un self-hosted runner dentro de
la red de DIINF.

Antes de configurar los secrets, confirma con TI/DIINF si:

1. El puerto SSH de la VM ya es accesible desde internet (aunque sea con
   autenticación por llave), o
2. Hay que instalar un [self-hosted runner de GitHub Actions](https://docs.github.com/en/actions/how-tos/manage-runners/self-hosted-runners/add-runners)
   dentro de la red de DIINF (recomendado si la VM está en una red interna/VPN) —
   en ese caso el workflow no necesita SSH entrante en absoluto, corre localmente en
   la VM y solo necesita salida hacia GitHub.

Si el punto 1 no es viable, dímelo y te dejo el workflow adaptado para self-hosted
runner en vez de SSH — es un cambio menor (`runs-on: self-hosted` en vez de
`runs-on: ubuntu-latest`, y el deploy pasa a ser un `cp` local en vez de `rsync`
remoto).

## 6. Checklist antes de anunciar la URL

- [ ] `nginx -t` sin errores y recargado.
- [ ] Usuario de deploy con llave pública instalada y permiso de sudo acotado.
- [ ] Los 4 secrets configurados en GitHub.
- [ ] Push de prueba a `main` → revisar pestaña **Actions** → el job termina en verde.
- [ ] `https://lsg.diinf.usach.cl/lsg-estudio/` responde 200 y muestra el QR/botón.
- [ ] El botón "Postular al estudio" apunta al link vigente del Google Form.
