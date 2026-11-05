# Instrucciones para agentes

## Propósito y fuentes de verdad

Este repositorio distribuye Camo y documenta su creación. No es una aplicación Vite, un monorepo ni un proyecto Node: no ejecutes pnpm, Turbo, ESLint o Vitest por defecto.

- README.md explica el resultado para personas; docs/CREAR_UN_PERSONAJE.md describe el proceso reproducible.
- pets/camo/pet.json y spritesheet.png son la distribución instalable.
- pets/camo/release.json conserva dimensiones, conteos y SHA-256 del archivo publicado. Debe coincidir con los bytes reales.
- assets/reference/personaje-aprobado.png define la apariencia que el usuario aprobó. Las vistas previas deben salir de la hoja final.

## Entorno de trabajo

- Python 3.10 o posterior con Pillow: `python -m pip install -r requirements.txt`.
- PowerShell para scripts/install-local.ps1; `-CodexHome` permite elegir el directorio de instalación.
- Usa rutas relativas al repositorio o resuélvelas desde `__file__`/`$PSScriptRoot`. No añadas rutas de equipos particulares.
- Para generar o modificar arte, usa ImageGen y lee la skill instalada `work-pets:create-pet` y sus referencias. Los scripts oficiales pertenecen a la skill; no están vendorizados aquí.
- No añadas claves, IDs personales de Pets, sesiones de upload, URLs firmadas, cachés, dependencias descargadas ni archivos ajenos al personaje.

## Convenciones de diseño

Conservar pelo negro, piel cálida, ojos en estrella/cruz sin pupilas añadidas, arete, chaqueta camuflada abierta, camiseta negra, vaqueros anchos con detalle rojo y zapatillas claras. La pose de tecleo es de pie y el portátil es negro y flotante. No agregar accesorios sin petición del usuario.

El usuario pidió explícitamente tecleo como `idle`, aunque la recomendación genérica de la skill sea un reposo más calmado. Mantén esa decisión. La carrera no lleva portátil. La pose suspendida no tiene un estado nativo asignado: no simules soporte ni sustituyas otro estado para hacerla pasar por integrada.

`running` significa trabajo activo y es distinto de `running-left`/`running-right`. Las miradas se expresan girando e inclinando la cabeza; no añadas pupilas ni gires todo el cuerpo para fingir la dirección.

## Cambios en imágenes y geometría

- ImageGen produce el dibujo. El código puede extraer, registrar, montar, limpiar bordes y codificar los píxeles generados, sin inventar ni redibujar poses.
- Conserva fuentes aprobadas y repara la fila mínima afectada. No regeneres la mascota completa por un fallo de extracción.
- Usa los scripts oficiales de la skill para extraer grupos conectados, montar y validar. No reemplaces sus puertas de calidad por verify_release.py.
- Mantén una escala compartida y una base estable. El salto debe despegar de verdad y aterrizar sin encoger al personaje.
- Genera las miradas en el orden de la guía: cardinales aprobados → fila 9 registrada → fila 10 con el mismo registro. No empalmes una pose nueva aislada en una fila aprobada.

## Verificación

Para cualquier cambio del paquete: `python scripts/verify_release.py` y `git diff --check`. Comprueba que los enlaces locales de los Markdown existan. Para cambios solo de documentación, no regeneres imágenes ni inventes pruebas de animación.

Si cambian los píxeles: ejecuta el flujo completo de extracción e inspección de la skill, revisión de movimiento, despill, validación v2, continuidad, semántica de las 16 miradas, revisión independiente y validate_pet_quality.py. Genera vistas previas a partir de los bytes finales y ejecuta el preflight de Pets. Actualiza SHA-256 y vistas previas únicamente después de validar esos mismos bytes. Nunca marques un informe como aprobado sin ejecutarlo.

No subas ni selecciones otra mascota por una modificación de README. No crees un duplicado de una mascota ya existente: consulta su identidad en la cuenta y usa el flujo correspondiente al cambio pedido. Una instalación local y una selección en el plugin son operaciones distintas; verifica y reporta cada una.

## Git y entregas

- Revisa el remoto antes de publicar. Repositorio previsto: `Kevinx1919/The-Best-Pet-in-Codex`.
- Usa ramas `codex/<descripcion>` para trabajo posterior salvo instrucciones del usuario.
- En commits o PR explica el cambio, qué se verificó y cualquier limitación real. No declares soporte del gesto suspendido ni sincronización automática entre escritorio y web.
- Antes de subir, revisa `git status`, el diff y el tamaño de archivos. No incluyas el directorio de trabajo original completo ni sus cachés.
