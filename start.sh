#!/bin/bash
minikube start --memory=4096m --cpus=2 --driver=podman network=host --addons metrics-server