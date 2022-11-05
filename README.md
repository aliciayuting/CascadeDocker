# How to use Cascade from docker image
## Running Environment
### Cascade runtime require:
- Ubuntu18 or Ubuntu20, with C++ compiler supporting C++17: GCC 8.3+, Python3.10

- More dependencies can be viewed on Cascade github repository: https://github.com/Derecho-Project/cascade.git


### Docker image runtime environment

To make the process of installing Cascade dependencies and compilation easier, we provide a docker image that you can directly run in an Ubuntu environment. Using the docker image, it automatically provides the correct environment and contains the required packages and the succesfully compiled executable for you to run Cascade.

The docker image needs to be run on Ubuntu environment, and the machine needs to contain ***\>= 2 CPUs and \>=800MB memory***

- Container environment: 
     - For windows user you can run the docker in the wsl2 (Windows Subsystem for Linux, which is a kernel built by Microsoft, allowing Linux containers to run natively without emulation)
     - You can also setup a container instance on Azure
- Virtual Machine(VM): 
Another easy way to access the environment is to use Virtual Machine, and select the virtual machine with at least 2 CPUs, and 800MB memory. 

## Docker Image
Here are the steps of how to pull the docker image:
1. ssh into the Ubuntu environment(container/virtual machine), install docker on the machine(container/VM)
2. run the below command to pull and run the docker image

```sudo docker run --privileged -d -it --name=tideenv yy354/cascadetide_docker:v1.0```

3. Then run the below command to shift the terminal to the docker image container that we just built

```sudo docker exec -it -u0  tideenv bash```

4. By now, you should be able to see the setup in the folder.
     - opt-dev folder contains all the dependencies and libraries needed to run Cascade
     - Derecho is a group management system that Cascade is built upon. Derecho folder contains all the build files for the Derecho program.
     - Cascade folder is the one we will be work with. Inside the cascade folder you can find a folder called build-Release. This folder contains successfully compiled executables. We will mainly work with this folder to run the Cascade server and Cascade client.

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
```


## Running Cascade
### Cascade System Structure
Cascade has a key-value sharding structure. That allows users to store objects, and compute using user defined logic. The server nodes on Cascade start the service, and the client nodes can interact with Cascade via put/get operations, JAVA API, Python API, Fuse file system, and other user defined logic.

### Running Cascade
- To start the Cascade service, you need to first run 4 Cascade server nodes to start the service. 
     1. Navigate to one of the server node configuration directory, using the command:
```cd ~/workspace/cascade/build-Release/src/service/cfg/n0```

     2. first clear out the previous log in this node's directory:
```rm -rf .plog/```

     2. Then start this server node via the command:
```../../cascade_server```

     3. Open a new terminal, and go to the docker container environment via: 
```sudo docker exec -it -u0  cascadeimageenv bash```

     4. Then Similar to step 1 and step 2, but with the second server node 
```cd ~/workspace/cascade/build-Release/src/service/cfg/n1```
```rm -rf .plog/```
```../../cascade_server```

     5. Repeat the process(step3 and step4) to start 2 server nodes in total. (n0 ~ n3)

- There are various way to use the Cascade service, here we provide the simplist K/V put/get way of accessing Cascade from terminal. More details of other functionalities and services provided by Cascade can be found here: https://github.com/Derecho-Project/cascade/tree/v1.0rc/src/service

     1. Open another terminal, and go to the docker container environment via: 
```sudo docker exec -it -u0  cascadeimageenv bash```

     2. Go the the 5th node
```cd ~/workspace/cascade/build-Release/src/service/cfg/n4``` 

     2. Then start running client via
```../../cascade_client```

     3. After the above command, you should be able to see the command prompt, ```cmd> help```, where you can type put/get operation, such as 
```put PCSS key1 value111 0 0``` (This command will put the object with key name: key1, and value: value111, from the subgroup 0 with subgroup type PCSS, in shard 0)
Then get this via 
```get PCSS key1 0 0``` (This command will get the object with key name: key1, from the subgroup 0 with subgroup type PCSS, shard 0)
The subgroup type denote the way to store the key,value pair, if choose VCSS(VolatileCascadeStoreWithStringKey) then only the most recent version would be stored; if choose PCSS(PersistentCascadeStoreWithStringKey) then all the historical versions would be stored.

     4. Programming with Python API.  To program a python code as client using python API, you need to first import the cascade_py package inside your python file, and create a Cascade client, using ```cascade_py.ServiceClientAPI()```. Then you can write put and get functions. Note that the subgroup type need to be the full name, such as PersistentCascadeStoreWithStringKey, or VolatileCascadeStoreWithStringKey
     ```
     #!/usr/bin/env python3
     from derecho.cascade.client import ServiceClientAPI
     if __name__ == '__main__':
          key1 = '/testkey01'
          value1 =bytes('foo'.encode())
          capi = ServiceClientAPI()
          ret = capi.put( key1, value1,subgroup_type='PersistentCascadeStoreWithStringKey', subgroup_index=0, shard_index=0)
          print(ret.get_result())
     ```
     To run this script you wrote, you need to move this python file (i.e. test.py) to the directory of ``` ~/workspace/cascade/build-Release/src/service/python/```, then in the current directory (``` ~/workspace/cascade/build-Release/src/service/cfg/n2```) to run ```python ../../python/test.py```


### Running Cascade via Python API
Please refer to the detailed tutorial: https://github.com/Derecho-Project/cascade/tree/v1.0rc/src/service/python 

###### Building Docker image, is refered to this github repository: https://github.coecis.cornell.edu/yw2399/Docker
