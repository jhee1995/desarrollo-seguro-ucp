# Estudio independiente – Sesión 5

Carga estimada: 6 horas (cierre de las 64 h de trabajo independiente del curso).

La sesión 5 cierra el arco: la IA que en la sesión 4 nos ayudó a encontrar y priorizar (el triage de Auditgate) es hoy el sistema que hay que asegurar. El objetivo del estudio es consolidar el repositorio del proyecto como producto final —con su gate corriendo y, si usan IA, sus guardarraíles— y dejar la sustentación lista.

## 1. Lecturas y actividades

| # | Actividad | Horas | Para qué |
|---|---|---|---|
| 1 | [OWASP Top 10 for LLM Applications 2025](https://genai.owasp.org/llm-top-10/): leer LLM01 (prompt injection), LLM05 (output handling) y LLM06 (excessive agency) a fondo. | 1,5 | Las tres fallas que concentran el riesgo de cualquier agente real. |
| 2 | Distinguir **inyección directa vs indirecta** y por qué una blocklist no basta. Escribir, para su proyecto, un ejemplo de inyección indirecta y la defensa de diseño. | 1 | El *instruction-source boundary*: el contenido que el agente lee es dato, nunca instrucción. |
| 3 | **Human-in-the-loop:** listar qué acciones de su proyecto (o de un agente que imaginen sobre él) serían *irreversibles* y deberían requerir confirmación humana. | 1 | El guardarraíl central: la IA propone, el humano y el determinismo disponen. |
| 4 | [NIST AI RMF](https://www.nist.gov/itl/ai-risk-management-framework) (las 4 funciones: Govern, Map, Measure, Manage) y una ojeada a [MITRE ATLAS](https://atlas.mitre.org/). | 1 | El vocabulario de gobernanza que piden las empresas. |
| 5 | **Cerrar el proyecto:** completar `proyecto/PLANTILLA.md` §5 (informe final: riesgos residuales, plan de remediación) y, si usan IA, la capa de IA/gobernanza. | 1,5 | El entregable es el repositorio completo, no un documento suelto. |
| | **Total** | **6** | |

## 2. Preguntas de autoevaluación

1. ¿Por qué el modelo no puede distinguir una instrucción de un dato, y qué consecuencia tiene eso para un agente que lee correos o páginas web?
2. Inyección directa vs indirecta: den un ejemplo de cada una sobre su propio proyecto. ¿Cuál es más peligrosa y por qué?
3. ¿Por qué una blocklist de frases («ignora tus instrucciones…») no resuelve la inyección? ¿Cuál es la defensa de diseño correcta?
4. Manejo inseguro de la salida (LLM05): si un agente genera SQL o HTML, ¿qué defensa de las sesiones 3 y 4 aplica, y por qué la salida del modelo es «entrada no confiable»?
5. Agencia excesiva: nombren las tres palancas (funcionalidad, permisos, autonomía) y cómo reducir cada una limita el daño de una inyección exitosa.
6. Human-in-the-loop: ¿qué relación tiene con el guardarraíl de Auditgate «el triage comenta pero no decide el merge»? Generalicen el principio.
7. ¿Por qué la cadena de suministro de modelos (LLM03/04) es análoga al SBOM que vimos en la sesión 4? ¿Qué sería un «SBOM de IA»?
8. WIF para el acceso al modelo: ¿por qué elimina la necesidad de guardar una llave de larga vida, y qué principio de la sesión 4 repite?
9. Privacidad: ¿cuál es el control de fuga más barato y efectivo sobre lo que se envía en un prompt? Relaciónenlo con la Ley 1581.
10. El arco de las cinco sesiones: expliquen en una frase cómo cada sesión agregó una capa sobre la misma idea de «que el error no dependa de que alguien se acuerde».

## 3. Sustentación

Preparen una defensa de ~10 minutos + preguntas que cuente **el repositorio**, no la teoría:

1. **Amenaza** (Lab 1): una amenaza STRIDE concreta de su proyecto.
2. **Verificación** (Lab 2): el requisito ASVS que la cubre y su evidencia.
3. **Gate** (Lab 3): el PR que la bloquea, en vivo, y la regla que la codifica.
4. **IA / gobernanza** (hoy): los guardarraíles si su proyecto usa IA, o su política de uso seguro de IA si no.

Guía y rúbrica completas en `proyecto/SUSTENTACION.md`.

## 4. Referencias

- OWASP Top 10 for LLM Applications: <https://genai.owasp.org/llm-top-10/>
- OWASP LLM — Prompt Injection: <https://genai.owasp.org/llmrisk/llm01-prompt-injection/>
- NIST AI Risk Management Framework: <https://www.nist.gov/itl/ai-risk-management-framework>
- MITRE ATLAS: <https://atlas.mitre.org/>
- Auditgate: <https://github.com/Jawy77/auditgate>
- Ley 1581 de 2012 (protección de datos personales, Colombia).
