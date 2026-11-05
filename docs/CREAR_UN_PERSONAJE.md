# Crear una mascota animada como Camo, paso a paso

Esta guía documenta el recorrido real: referencia visual → personaje aprobado → animaciones → adaptación al reproductor → validación → instalación. No hace falta programar una aplicación para distribuir la mascota, pero sí preparar correctamente sus imágenes.

## 1. Elegir el destino antes de animar

Identifica si la mascota aparecerá en ChatGPT Work mediante Pets, en el escritorio o en otra aplicación. Consulta las herramientas del plugin y la documentación de la versión instalada. Una demo propia puede admitir gestos que el reproductor nativo no expone.

En Camo comprobamos el cargador local de Codex sin modificarlo. Admitía `pet.json`, PNG/WebP y las hojas v1/v2. Permitía carrera al arrastrar, pero no un estado separado para mantener pulsado sin mover. El usuario eligió continuar con la integración nativa y conservar el prototipo suspendido aparte.

## 2. Reunir las referencias

Asigna a cada imagen un papel: estilo, ropa, pelo/piel, accesorio o movimiento. No mezcles todos esos papeles de forma implícita.

Para Camo se definieron contorno negro grueso, ojos en estrella/cruz, ropa holgada, chaqueta camuflada abierta, camiseta negra, pantalón oscuro con detalle rojo y zapatillas grises. Después se añadió un arete con facetas y reflejos. La referencia de movimiento solo aportó la mecánica de la carrera, no cambió la ropa ni la identidad.

## 3. Aprobar una imagen principal

Genera el personaje completo con ImageGen y fondo transparente. Define la altura relativa de cabeza/cuerpo, peinado, silueta y paleta. Revisa también cómo se lee en pequeño.

Corrige una cosa por iteración y conserva revisiones. No empieces a producir todos los movimientos antes de aprobar la identidad. La referencia final de este proyecto está en `assets/reference/personaje-aprobado.png`.

## 4. Definir estados y transiciones

Describe qué se ve y cuándo se activa. En este caso: reposo = tecleo de pie; desplazamiento horizontal durante arrastre = carrera en la dirección correspondiente. Al soltar se vuelve al estado que el reproductor determine según su actividad.

La demo inicial tenía tres gestos personalizados; la integración nativa conserva solo los que el reproductor soporta. No prometas alternancia aleatoria ni una velocidad configurable sin comprobarlo.

## 5. Preparar el proyecto con la skill Pets

Lee `work-pets:create-pet`, su contrato de sprite sheet y las instrucciones de upload. Localiza su carpeta instalada y los scripts que incluye. Guarda un brief, las fuentes aprobadas, prompts, revisiones y entregables. Si existe Library, conserva allí los artefactos; en esta sesión solo se pudo conservar la copia del proyecto local.

Ejemplo de preparación, sustituyendo las rutas por las de tu equipo:

```powershell
$SKILL_DIR = 'RUTA/A/skills/create-pet'
$RUN_DIR = 'RUTA/A/mi-mascota'
python "$SKILL_DIR/scripts/prepare_pet_run.py" --pet-name "Mi mascota" --description "Descripción breve" --reference "personaje.png" --pet-notes "Rasgos que deben conservarse" --style-preset sticker --output-dir "$RUN_DIR"
```

Lee los archivos `pet_request.json` e `imagegen-jobs.json` producidos. Respeta las dependencias de generación y el color de extracción elegido. Camo utilizó cian `#00FFFF`, que contrasta con su ropa; no se debe usar verde como fondo de extracción para un personaje verde.

## 6. Crear las nueve tiras estándar

Los conteos por fila son **6, 8, 8, 4, 5, 8, 6, 6, 6** para idle, carrera derecha, carrera izquierda, saludo, salto, error, espera, trabajo y revisión. El README describe cada estado de Camo.

Adjunta siempre la base aprobada y las referencias que definan identidad y accesorios; usa la guía de distribución para separar las poses, sin dibujar sus líneas. Genera cada estado con su acción propia. Mantén cuerpos completos, escala estable, separación y transparencia o un fondo removible uniforme. No pidas al generador el atlas final entero.

Después de cada tira ejecuta los scripts oficiales:

```sh
python "$SKILL_DIR/scripts/extract_strip_frames.py" --decoded-dir "$RUN_DIR/decoded" --output-dir "$RUN_DIR/qa/rows/idle/frames" --states idle --method auto
python "$SKILL_DIR/scripts/inspect_frames.py" --frames-root "$RUN_DIR/qa/rows/idle/frames" --states idle --require-components --json-out "$RUN_DIR/qa/rows/idle/review.json"
```

Cambia `idle` por el estado correspondiente. Recupera grupos completos y registra los fotogramas con una escala compartida; evita cortar poses suponiendo que cada imagen generada trae celdas perfectas. Solo refleja la carrera si los detalles asimétricos siguen siendo correctos. En Camo se generaron ambas direcciones.

## 7. Montar y revisar las animaciones estándar

Reúne los fotogramas, ejecuta `inspect_frames.py`, `compose_atlas.py`, `make_contact_sheet.py` y `render_animation_previews.py`. Mira los bucles y las transiciones, no solo una imagen estática.

En Camo la revisión automática inicial pasó, pero al ver la hoja detectamos que el personaje se hacía pequeño durante el salto. Se corrigió el registro con una escala común de cuerpo y una trayectoria que cabía en la celda, manteniendo un despegue real de 13 px y aterrizaje alineado. Una validación estructural no sustituye la revisión visual.

## 8. Añadir las dieciséis miradas

La v2 añade dos filas. Antes escribe cómo mira el personaje: en Camo gira e inclina físicamente la cabeza, conserva sus ojos dibujados y mantiene anclados torso, pies y portátil.

1. Genera cuatro cardinales: arriba `000`, derecha `090`, abajo `180`, izquierda `270`, siempre en coordenadas de pantalla.
2. Extrae y revisa con `extract_cardinal_anchors.py`; crea la referencia aprobada con `compose_cardinal_anchor_strip.py`.
3. Genera fila 9 en orden: `000, 022.5, 045, 067.5, 090, 112.5, 135, 157.5`.
4. Regístrala con `assemble_extended_atlas.py` y guarda su transformación antes de continuar.
5. Genera fila 10: `180, 202.5, 225, 247.5, 270, 292.5, 315, 337.5`, utilizando el mismo registro.

No confundas arriba con la pose frontal neutra. Comprueba las cuatro direcciones principales y el cierre del bucle. Si hay una dirección equivocada, repara la fila coherente afectada. En Camo se descartó un primer intento con diagonales invertidas.

## 9. Validar el atlas final

El resultado v2 debe medir **1536 × 2288**, con celdas **192 × 208**, 73 fotogramas obligatorios y 15 celdas vacías transparentes. Usa PNG o WebP dentro del límite de 20 MiB del contrato.

Ejecuta, en orden, los scripts de la skill: limpieza `despill_chroma_edges.py` una vez sobre la versión final; `validate_atlas.py --require-v2`; hojas de contacto y de miradas; `measure_direction_continuity.py`; registro de evidencia visual para las 16 direcciones; y `validate_pet_quality.py`. Cuando haya revisores independientes, realiza también la revisión ciega de ejes con los scripts correspondientes.

Conserva los informes reales. Corrige cualquier error antes de subir. Si cambias los píxeles después de validar, los informes dejan de representar ese archivo y hay que repetir las comprobaciones afectadas.

## 10. Mostrar el movimiento que se va a publicar

Renderiza desde los bytes finales: nueve GIF, vista de todos los estados, video MP4, transición idle→salto→idle, bucle de miradas y varias imágenes fijas. Camo conserva estos resultados en `assets/previews/`.

Muestra el movimiento antes de registrar la mascota. Una vista previa antigua o de otra hoja no demuestra la calidad del archivo final.

## 11. Registrar y activar en ChatGPT Work

Mediante el plugin Pets:

1. `validate_pet_spritesheet(file=RUTA_ABSOLUTA)` y comprobar `valid: true`.
2. `prepare_pet_upload(file=LA_MISMA_RUTA)`.
3. Usar `upload.upload_session_id` en `create_pet`, junto con nombre y descripción.
4. Conservar el `pet.id` estable devuelto. No usar una URL temporal como identidad.
5. `select_pet(pet_id=ID)` cuando el usuario quiera activarla.
6. Consultar todas las páginas de `list_pets` hasta verificar el ID y su estado activo.

No publiques sesiones de upload ni enlaces firmados en Git. Antes de repetir una creación tras una interrupción, consulta si la mascota ya existe para evitar duplicados.

## 12. Instalar la copia local y documentar

Para el cargador local inspeccionado, crea una carpeta bajo el directorio `pets` de Codex con la hoja final y un manifiesto:

```json
{
  "displayName": "Camo",
  "description": "Personaje urbano con portátil y carrera al arrastrar.",
  "spriteVersionNumber": 2,
  "spritesheetPath": "spritesheet.png"
}
```

El script `scripts/install-local.ps1` instala esta distribución. Actualiza el selector de mascotas y elige Camo. El registro del plugin y la copia local son independientes; verifica cada destino y no anuncies una selección de escritorio que no hayas observado.

Termina con README para personas, AGENTS.md para agentes, referencias y vistas previas necesarias, un manifiesto de integridad y esta guía. Publica únicamente los archivos del proyecto: excluye rutas personales, identificadores de cuenta, credenciales, dependencias descargadas y archivos de otros trabajos.
