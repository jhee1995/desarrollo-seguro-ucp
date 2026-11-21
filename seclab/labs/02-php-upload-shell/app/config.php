<?php
// VULNERABLE A PROPOSITO — secretos hardcodeados (OWASP A05 / CWE-798).
// El escaner de secretos (gitleaks) debe cazarlos. Las llaves AWS son las
// de ejemplo publicas de la documentacion (no reales), solo didacticas.
$DB_PASS               = "S3cr3t_Pa55w0rd_de_produccion";
$AWS_ACCESS_KEY_ID     = "AKIAIOSFODNN7EXAMPLE";
$AWS_SECRET_ACCESS_KEY = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY";
$GITHUB_TOKEN          = "ghp_016C7f5A9bQwErTyUiOpAsDfGhJkL0mN3oP4";
