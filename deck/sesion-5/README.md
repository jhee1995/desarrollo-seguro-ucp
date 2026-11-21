# Deck de la sesión 5

Fuentes del deck «Desarrollo Seguro UCP – Sesión 5»: 21 diapositivas, una por archivo, en el mismo formato que los decks de las sesiones 1 a 4. `build.py` genera `deck.json` y `slides/` (`python3 build.py /_blob/<id-del-logo>`).

El hilo de la sesión cierra el arco del curso: la IA que en la sesión 4 fue **herramienta** (el triage de Auditgate, que encontró y priorizó sin decidir el merge) hoy es el **objeto de estudio**. Aseguramos los sistemas de IA que usamos para construir, y cada equipo sustenta el recorrido completo del proyecto.

| Bloque | Diapositivas |
|---|---|
| Encuadre | `cover`, `agenda`, `repaso` |
| El problema · la IA como superficie | `superficie-ia`, `llm-top10`, `casos` |
| Prompt injection | `inyeccion`, `demo-inyeccion`, `salida` |
| Agencia y guardarraíles | `agencia`, `hitl`, `guardarrailes` |
| Gobernanza | `gobernanza`, `wif`, `privacidad` |
| Sustentación | `sustentacion`, `entregable2`, `rubrica` |
| Cierre del curso | `arco`, `recursos`, `cierre` |

## Demo en vivo

| Slide | Flujo | Nota |
|---|---|---|
| `demo-inyeccion` | Inyección **indirecta** conceptual: una página con un payload embebido que intenta secuestrar al agente que la lee | Demo sin payload funcional. El punto es el principio de diseño (el contenido leído es dato, nunca instrucción), no una blocklist de frases. |

No hay comandos ofensivos: la sesión 5 se enseña con el principio del *instruction-source boundary* (las instrucciones válidas vienen solo del canal del usuario) y con el guardarraíl human-in-the-loop que el propio curso practica.

## Marco de referencia

- OWASP Top 10 for LLM Applications (2025): <https://genai.owasp.org/llm-top-10/>
- NIST AI Risk Management Framework: <https://www.nist.gov/itl/ai-risk-management-framework>
- MITRE ATLAS (tácticas de ataque a sistemas de IA): <https://atlas.mitre.org/>

## Ajustes antes de dictar

- **Horario:** la `agenda` usa bloques sin hora fija; ajusta los tiempos al bloque real del sábado 21.
- **Numeración de entregas:** el slide `entregable2` está alineado con `proyecto/PLANTILLA.md` (el pipeline es el «entregable 2» §4, hecho en el Lab 3; hoy se cierra el informe final §5 + la capa de IA/gobernanza). Ajusta a tu programa si difiere.
- **Rúbrica de sustentación:** es una propuesta (`rubrica`); alinéala con los pesos reales del proyecto integrador.

| Recurso | Archivo en el repositorio |
|---|---|
| `81762f76e0e02006203e5a8a9b3904d5` | Logo de la UCP (versión para fondo oscuro), tomado de ucp.edu.co; no se incluye en el repositorio |
