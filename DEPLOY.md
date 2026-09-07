# Despliegue de `lsg-landing-page-estudio`

URL de producción: **https://lsg.diinf.usach.cl/lsg-estudio/**

## Por qué manual (historial de decisiones)

Se probaron dos rutas de CI/CD antes de esta:

1. **Push-based por SSH** (GitHub Actions → `rsync` a la VM): falló con
   `Operation timed out` — el `ufw` de la VM permite el puerto 22, pero un
   firewall de red de DIINF/USACH descarta las conexiones SSH entrantes desde IPs
   dinámicas como las de los runners de GitHub.
2. **Self-hosted runner** en la VM: técnicamente viable (evita el problema de
   SSH entrante), pero se optó por no seguir esa ruta por ahora.

Se decidió ir con **deploy manual**: un `git pull` + copiar el archivo. Dos
comandos, cero infraestructura adicional, control total sobre cuándo se publica
un cambio — razonable para una landing de una sola página que no cambia seguido.

## Deploy (dos líneas)

Parado en cualquier lado de la VM, con el checkout del repo en
`~/lsg-landing-page-estudio`:

```bash
cd ~/lsg-landing-page-estudio && git pull origin main
cp ~/lsg-landing-page-estudio/index.html /var/www/lsg-estudio/index.html
```

**No hace falta `sudo systemctl reload nginx`** para esto: el `location
/lsg-estudio/` usa `alias`, que le sirve el archivo directo del disco en cada
request. `reload` solo es necesario si cambia la config de nginx (el bloque
`server{}` en sí), no el contenido HTML.

O con el script incluido, que hace lo mismo y confirma el commit desplegado:

```bash
cd ~/lsg-landing-page-estudio
bash scripts/deploy.sh
```

## Verificar

```bash
curl -I https://lsg.diinf.usach.cl/lsg-estudio/
```

Debería responder `200 OK`.

## Setup de la VM ya hecho (referencia, no repetir)

Para contexto de por qué el deploy funciona con solo estos dos comandos — esto
ya está configurado en la VM, documentado acá por si hay que reconstruirlo:

- `/var/www/lsg-estudio` existe, con dueño `jmacias:www-data`.
- Bloque nginx en `/etc/nginx/sites-available/bgames.conf` (el archivo activo,
  con symlink en `sites-enabled/`) tiene el `location /lsg-estudio/` apuntando
  con `alias` a ese directorio.
- El checkout de este repo vive en `~/lsg-landing-page-estudio` en la VM, con
  `origin` apuntando a `https://github.com/jmaciascaceres-lab/lsg-landing-page-estudio`.

## Pendiente de limpieza (si no se hizo ya)

Si en algún momento se instaló un self-hosted runner o se generaron secrets de
SSH para el intento anterior, y no se revirtió:

- Borrar el runner desde GitHub → Settings → Actions → Runners (botón Remove),
  usando `./config.sh remove --token <...>` en la VM antes de borrar sus
  archivos de credenciales.
- Borrar los secrets `DEPLOY_HOST`, `DEPLOY_USER`, `DEPLOY_SSH_KEY`,
  `DEPLOY_PATH` en GitHub → Settings → Secrets and variables → Actions, si
  quedaron de un intento anterior.
- Confirmar con `git status` en `~/lsg-landing-page-estudio` que no quedaron
  archivos sueltos del paquete del runner (`bin/`, `externals/`, `config.sh`,
  `.credentials`, etc.) mezclados con el repo.

## Checklist antes de anunciar la URL

- [ ] `git pull` + `cp` corridos, `git rev-parse --short HEAD` coincide con el
      último commit en GitHub.
- [ ] `curl -I https://lsg.diinf.usach.cl/lsg-estudio/` → `200`.
- [ ] Botón "Postular al estudio" apunta al link vigente del Google Form.
- [ ] `~/lsg-landing-page-estudio` está limpio (`git status` sin archivos
      sueltos del intento de runner).
