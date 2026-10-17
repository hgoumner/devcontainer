include .env
export

all: podman_setup container certificates container_python

podman_create:
	podman machine init --cpus 4 --memory 10240 --disk-size 100 --provider applehv

podman_start:
	podman machine start

podman_stop:
	podman machine stop

podman_restart: podman_stop podman_start

podman_setup:
	bash ./setup/setup_podman.sh

container:
	bash ./setup/setup_container.sh

container_python:
	bash ./setup/setup_container_python.sh

certificates:
	bash ./setup/setup_certificates.sh

