import docker

def stop_container(container_name):
    try:
        print("Stopping container {}".format(container_name))
        docker_client.containers.get(container_name).stop()
    except Exception as e:
        print(str(e))

def start_container(container_name):
    try:
        print("Starting container {}".format(container_name))
        docker_client.containers.get(container_name).start()
    except Exception as e:
        print(str(e))

docker_client = docker.from_env()
