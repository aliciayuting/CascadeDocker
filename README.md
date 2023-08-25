# How to use Cascade from docker image
## Running Environment
### Overview about Cascade:
This is a docker image based on open-sourced project Cascade, more details on Cascade could be viewed at Cascade github repository: https://github.com/Derecho-Project/cascade.git


### Docker image runtime environment

As a quick-start to Cascade, we provide a docker image that you can directly download and run. In the docker image, it has pre-built the correct environment, the required packages and the compiled executable for Cascade to run.

The docker image needs to be run in an Ubuntu environment, and needs to be allocated with ***\>= 2 CPUs and \>=800MB memory***

- Container environment: 
     - For windows user you can run the docker in the wsl2 (Windows Subsystem for Linux, which is a kernel built by Microsoft, allowing Linux containers to run natively without emulation)
     - You can also setup a VM or linux container instance on the local machine or cloud server to run
- Virtual Machine(VM): 
Another easy way to access the environment is to use Virtual Machine, and select the virtual machine with at least 2 CPUs, and 800MB memory. 

## Docker Image
Here are the steps of how to pull the docker image:
1. In the Ubuntu environment, install docker on the machine(container/VM)
2. run the below command to pull and run the docker image

```sudo docker run --network host --gpus all -P --privileged -d -it --name=casenv yy354/cascade_docker_ml:v2.0```


```yy354/cascade_docker:v1.0``` is the docker image name.

```--network host``` flag is to enable the container to access the host's network. Another way is to use bridge network with [port forwarding](https://docs.docker.com/network/drivers/bridge/), by creating a bridge network via: ```docker network create --subnet=<subnet_cidr> mynetwork``` and ```--network mynetwork -p <container_ip>``` flag when running docker run.

```--gpus all``` flag is to enable the container to access the host's gpu

3. Then run the below command to shift the terminal to the docker image container that we just built

```sudo docker exec -it -u0  casenv bash```

4. By now, you should be able to see the setup in the folder.
     - example folder contains the starter code with examples. More details can be found at: https://github.com/aliciayuting/CascadeDocker/blob/py_udl_docker/Cascade_Ubuntu/README.md
     - opt-dev folder contains all the dependencies and libraries needed to run Cascade
     - Derecho is a group management system that Cascade is built upon. Derecho folder contains all the build files for the Derecho program.
     - Cascade folder contains the implementation and executable of cascade. Inside the cascade folder you can find a folder called build-Release. This folder contains successfully compiled executables. We will mainly work with this folder to run the Cascade server and Cascade client.

```bash
.
|-- opt-dev
|   |-- bin
|   |-- etc
|   |-- lib
|   |-- sbin
|   |-- share
|-- workspace
    |-- cascade
    |   |-- CMakeLists.txt
    |   |-- CODE_OF_CONDUCT.md
    |   |-- LICENSE
    |   |-- README.md
    |   |-- build-Release
    |   |-- build.sh
    |   |-- cascadeConfig.cmake
    |   |-- config.h.in
    |   |-- include
    |   |-- scripts
    |   |-- src
    |-- derecho
    |   |-- CMakeLists.txt
    |   |-- Doxyfile
    |   |-- LICENSE
    |   |-- README.md
    |   |-- build-Release
    |   |-- build.sh -> scripts/build/build.sh
    |   |-- cmake
    |   |-- compile_commands.json -> build-Release/compile_commands.json
    |   |-- derechoConfig.cmake
    |   |-- githooks
    |   |-- include
    |   |-- scripts
    |   |-- src
    |-- prerequisites
|-- examples
```


## Running Cascade
Check on this link for more details: https://github.com/aliciayuting/CascadeDocker/blob/main/Cascade_Ubuntu/README.md
