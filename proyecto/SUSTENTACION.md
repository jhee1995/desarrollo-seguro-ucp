# Sustentación del proyecto integrador · Sesión 5

**Sábado 21 de noviembre · sesión de cierre**

La sustentación es la evaluación integradora del curso. No es una exposición de teoría: cada equipo muestra **su repositorio** contando una sola historia —de la amenaza al control que la bloquea— y, si usa IA, cómo la gobierna.

## Formato

- **Duración:** ~10 minutos de presentación + 5 minutos de preguntas por equipo.
- **Qué se proyecta:** el repositorio del equipo (no solo diapositivas). Se espera **demo en vivo del gate**.
- **Orden:** por sorteo al inicio de la sesión.

## El hilo a contar (el arco de las 4 sesiones)

| Paso | Qué muestran | De dónde sale |
|---|---|---|
| 1 · **Amenaza** | Una amenaza STRIDE concreta y priorizada de su aplicación | Lab 1 (modelo de amenazas) |
| 2 · **Verificación** | El requisito ASVS 5.0 que la cubre y su evidencia (archivo:línea o prueba) | Lab 2 (tabla ASVS) |
| 3 · **Gate** | Un PR que introduce esa falla, el `Security Gate` en rojo, el fix y el verde. La **regla** que la codifica | Lab 3 (gate + regla) |
| 4 · **IA / gobernanza** | Si el proyecto usa IA: los guardarraíles (injection, salida, agencia). Si no: su política de uso seguro de IA | Sesión 5 |

La clave es la **trazabilidad**: que amenaza → prueba → gate sean el mismo hilo visible en el repo, no piezas sueltas.

## Qué entregar (entrega final)

En el repositorio del equipo, con `proyecto/PLANTILLA.md` completo:

1. **§1–2 · Contexto y modelo de amenazas** (ya en Entregable 1).
2. **§3 · Requisitos y controles** ASVS (ya en Entregable 1).
3. **§4 · Pipeline DevSecOps** — el gate instalado y requerido (Entregable 2 / Lab 3).
4. **§5 · Informe final** — riesgos residuales, plan de remediación priorizado, recomendaciones.
5. **§6 · Seguridad de IA y gobernanza** — la capa de hoy (ver plantilla).

## Rúbrica de la sustentación (propuesta)

> Ajústala a los pesos reales del proyecto integrador en el programa del curso.

| Criterio | Peso | Sobresaliente | Aceptable | Insuficiente |
|---|---|---|---|---|
| **Trazabilidad del arco** | 30 % | Amenaza → prueba → gate es un solo hilo visible en el repo | El hilo existe pero con saltos o piezas sueltas | No se ve la conexión entre amenaza, prueba y control |
| **Demo del gate en vivo** | 25 % | Un PR bloquea por una falla real y pasa a verde tras el fix, en vivo | Se muestra un PR histórico, no en vivo | No hay gate corriendo |
| **Capa de IA / gobernanza** | 25 % | Guardarraíles concretos (o política) frente a injection, salida y agencia | Mención superficial de riesgos de IA | Ausente |
| **Claridad y respuestas** | 20 % | Explican decisiones y responden con criterio técnico | Responden lo básico | No sostienen las preguntas |

El peso está en lo demostrable: el hilo trazable y el gate corriendo valen más de la mitad. La diapositiva es el envoltorio; el repositorio es la nota.
