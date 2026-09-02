# lsg-landing-page-estudio

Landing page de convocatoria para el estudio experimental **LifeSync-Games (LSG)** —
InTeractiOn Research Lab, Depto. de Ingeniería Informática, USACH.

Aprobado por el Comité de Ética Institucional USACH (Informe N° 231/2026).

## Qué es esto

Página estática de una sola vista (`index.html`, sin build step, sin dependencias
externas de fuentes/CDN) que explica el estudio, muestra los requisitos de
elegibilidad y enlaza al [formulario de interés](https://forms.gle/rCC7Ku4FphNn7GJNA).
Reutiliza el mismo copy validado del afiche de reclutamiento y del formulario, para
mantener consistencia entre los tres materiales.

Se sirve en producción en:

```
https://lsg.diinf.usach.cl/lsg-estudio/
```

(junto a `lsg-auth`, `lsg-core-api` y `lsg-status` bajo el mismo host).

## Estructura

```
.
├── index.html                       # la landing completa (HTML+CSS inline, sin JS)
├── README.md
├── DEPLOY.md                        # guía de despliegue (nginx, secrets, SSH)
└── .github/workflows/deploy.yml     # CI/CD: push a main -> rsync a la VM de DIINF
```

## Editar contenido

Es un solo archivo HTML plano. Los bloques relevantes:

- `.hero h1` / `.hero .lede` → titular y frase de enganche.
- `.req-grid` → los 4 requisitos de elegibilidad (18+, ≥3h/semana, RM, laptop+smartphone).
- `.qr-card` → el QR embebido en base64 y el link al formulario. Si cambia el link del
  formulario, regenerar el QR y reemplazar el `data:image/png;base64,...`.
- `.contact-grid` y `.cei` → datos de contacto e Informe Ético.

**Importante:** si cambian los criterios de elegibilidad o el link del formulario, hay
que actualizarlo en tres lugares para mantener consistencia: el afiche de reclutamiento,
el Google Form, y este `index.html`.

## Despliegue

Push-based vía GitHub Actions: cada push a `main` dispara
`.github/workflows/deploy.yml`, que hace `rsync` del contenido hacia la VM de DIINF
sobre SSH (usando una llave dedicada guardada como secret del repo) y recarga nginx.

Requiere que la VM acepte SSH entrante desde los runners de GitHub (IP dinámica, no
fija) — si eso no es viable por firewall, ver la nota de self-hosted runner en
`DEPLOY.md`.

Guía completa (bloque nginx, generación/instalación de la llave SSH, secrets de
GitHub, checklist de salida a producción) en [`DEPLOY.md`](./DEPLOY.md).

## Créditos

González-Ibáñez, R., Macías-Cáceres, J., Villalta-Paucar, M. (2025). LifeSync-Games:
Toward a Video Game Paradigm for Promoting Responsible Gaming and Human Development.
arXiv preprint: 2510.19691 [cs.HC].
