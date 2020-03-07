import docker

def stop_container(container_name):
    docker_client.containers.get(container_name).stop()

def start_container(container_name):
    docker_client.containers.get(container_name).stop()

docker_client = docker.from_env()
