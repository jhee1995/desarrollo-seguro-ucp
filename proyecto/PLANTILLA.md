# Proyecto integrador – Plantilla

Copien este archivo al repositorio de su equipo y complétenlo a lo largo del curso.

## Equipo

- Integrantes:
- Repositorio del proyecto:

## 1. Contexto (entregable 1)

- Aplicación y propósito:
- Usuarios y datos que maneja (¿datos personales? ¿financieros?):
- Obligaciones normativas aplicables (Ley 1581, ISO/IEC 27001, CRA, sector):
- Diagrama de arquitectura (adjuntar imagen):

## 2. Modelo de amenazas (entregable 1)

- Archivo de OWASP Threat Dragon:
- Límites de confianza identificados:
- Amenazas STRIDE priorizadas:

| ID | Amenaza | Categoría STRIDE | Impacto | Probabilidad | Requisito ASVS |
|---|---|---|---|---|---|
| T1 | | | | | |

## 3. Requisitos y controles

| Requisito ASVS 5.0 | Control implementado | Evidencia (commit, prueba) | Estado |
|---|---|---|---|
| | | | |

## 4. Pipeline DevSecOps (entregable 2)

- Workflow de GitHub Actions:
- Etapas: secretos, SAST, SCA, imágenes, DAST, IaC, SBOM, firma
- Políticas de bloqueo:

## 5. Informe final

- Checklist ASVS L1 (adjuntar):
- Riesgos residuales:
- Plan de remediación priorizado:
- Recomendaciones al negocio:

## 6. Seguridad de IA y gobernanza (sesión 5)

Completen esta sección si el proyecto usa IA (un LLM, un agente, una API de modelo). Si no la usa, documenten la **política de uso seguro de IA** que aplicarían.

- ¿El proyecto usa IA? ¿Dónde (chatbot, agente, clasificación, generación)?:
- **Modelo de amenazas del componente de IA** (marquen lo aplicable):
  - [ ] Prompt injection (directa / indirecta) — ¿qué contenido no confiable llega al modelo?:
  - [ ] Manejo inseguro de la salida (LLM05) — ¿la salida entra a un intérprete, DB o HTML?:
  - [ ] Agencia excesiva (LLM06) — ¿qué herramientas y permisos tiene el agente?:
  - [ ] Fuga de datos sensibles (LLM02) — ¿qué datos salen en el prompt?:
- **Guardarraíles aplicados** (entrada / ejecución / salida):
- **Human-in-the-loop:** ¿qué acciones irreversibles requieren confirmación humana?:
- **Gobernanza:** procedencia del modelo, acceso sin llaves de larga vida (WIF/OIDC), retención de prompts, auditoría:
- **Minimización de datos:** ¿qué PII o datos sensibles se excluyen del prompt? (Ley 1581):
