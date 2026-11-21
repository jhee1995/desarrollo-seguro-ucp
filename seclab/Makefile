# SecLab — DevSecOps didáctico. Todo con un comando. Solo necesitas Docker.
# Uso:  make help
LAB ?= 02-php-upload-shell

.PHONY: help scan scan-all cook demo up down logs triage monitor monitor-down labs clean

help:            ## Muestra esta ayuda
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	 awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-16s\033[0m %s\n",$$1,$$2}'

scan:            ## Escanea un lab:  make scan LAB=03-node-cmd-injection
	@./bin/scan.sh labs/$(LAB)

scan-all:        ## Escanea TODOS los labs (gate sobre todo el árbol)
	@./bin/scan.sh labs

cook:            ## Solo la animación de Heisenberg (prueba)
	@./bin/heisenberg.sh --demo

demo:            ## Levanta un lab, corre el exploit y lo baja:  make demo LAB=02-...
	@( cd labs/$(LAB) && docker compose up -d --build && sleep 4 && ./exploit.sh ); \
	 docker compose -f labs/$(LAB)/docker-compose.yml down -v

up:              ## Levanta un lab:  make up LAB=01-log4shell
	@cd labs/$(LAB) && docker compose up -d --build

down:            ## Baja un lab
	@cd labs/$(LAB) && docker compose down -v

logs:            ## Logs de un lab
	@cd labs/$(LAB) && docker compose logs -f

triage:          ## Agente: prioriza y explica el último reporte
	@./bin/triage.sh

monitor:         ## Levanta Grafana + Prometheus + Pushgateway (http://localhost:3001)
	@cd monitoring && docker compose up -d && \
	 echo "\n  Grafana:    http://localhost:3001  (admin / seclab)" && \
	 echo "  Prometheus: http://localhost:9090\n"

monitor-down:    ## Baja el monitoreo
	@cd monitoring && docker compose down

labs:            ## Lista los labs disponibles
	@ls -1 labs | sed 's/^/  /'

clean:           ## Borra el estado de escaneos previos
	@rm -rf .state/* && echo "estado limpiado"
