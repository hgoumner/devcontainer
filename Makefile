include .env
export

all: setup_podman setup_container setup_certificates setup_container_python

create_podman_machine:
	podman machine init --cpus 4 --memory 10240 --disk-size 100 --provider applehv

start_podman_machine:
	podman machine start

stop_podman_machine:
	podman machine stop

restart_podman_machine: stop_podman_machine start_podman_machine

setup_podman:
	bash ./setup/setup_podman.sh

setup_container:
	bash ./setup/setup_container.sh

setup_container_python:
	bash ./setup/setup_container_python.sh

setup_certificates:
	bash ./setup/setup_certificates.sh

