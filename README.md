# Landing Page LifeSync-Games

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
├── index.html          # la landing completa (HTML+CSS inline, sin JS)
├── README.md
├── DEPLOY.md            # guía de despliegue manual
└── scripts/deploy.sh    # git pull + copiar index.html (dos comandos, sin CI/CD)
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

Manual: `git pull` en la VM + copiar `index.html` al directorio que sirve nginx
(`/var/www/lsg-estudio`). Se descartó CI/CD automático (tanto push-based por SSH
como self-hosted runner) por ahora — ver el porqué y los dos comandos exactos en
[`DEPLOY.md`](./DEPLOY.md).

## Changelog

### 2026-09-08

- Cambiar el titulo de "¿Juegas seguido videojuegos?" a "¿Juegas habitualmente videojuegos?" en index.html y
  afiche_LSG_vertical.html.

## Créditos

- [1] González-Ibáñez, R., Macías-Cáceres, J., Villalta-Paucar, M. (2025). LifeSync-Games: A Technical Note on a
  Novel Framework for Video Game Development. 2025 44th International Conference of the Chilean Computer Science
  Society (SCCC), Valparaiso, Chile, pp. 1-4, doi: 10.1109/SCCC67219.2025.11420722.<br>
- [2] González-Ibáñez R., Macías-Cáceres J., Villalta-Paucar M., (2025). LifeSync-Games: Toward a Video Game
  Paradigm for Promoting Responsible Gaming and Human Development. arXiv preprint: 2510.19691 [cs.HC].<br>
- [3] Macías-Cáceres J., Gutiérrez-Vela F., Paderewski-Rodriguez P., González-Ibáñez, R., (2026). LifeSync-Games:
  Signal-Driven Pervasive Game Design: The LifeSync-Games Framework as a Player Experience Integration Layer. arXiv
  preprint: 2609.03169 [cs.HC].
