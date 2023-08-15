# Overview
Cascade is a C++17 cloud application framework powered by optimized RDMA data paths. It provides a K/V API for data manipulation in distributed memory and persistent storage. Besides the K/V API, Cascade allows injecting logic on the data paths for low-latency application. 

This docker image contains Cascade three examples and interfaces, demonstrating how to run and customize it to your application scenerio.

Examples:
- C++ User defined logic (UDL) 

- Python User defined logic
     - word count example
     - console printer printout example
     - Resnet ML model example


Interfaces: 
- Command line client API interacts with Cascade Servers

- Python client API interacts with Cascade Servers

- User Defined Logic to the data path

     - User could define function/logic in C++ as a dynamic linked library(.so file) to preload to Cascade Server 

     - User could define function/logic in Python code, then the pre-written python_udl.so file will load the Python code to Cascade Server address space to call the Python function user defined


# Directories


```bash
/root
|-- example:
|   |-- user_defined_logic
     |   |-- console_printer_cfg: contains the cascade servers & client configs
          |   |-- n0: include configs for Cascade Server node n0 to start: dfgs.json, layout.json, udl_dlls.cfg, derecho.cfg
          |   |-- n1: include configs for Cascade Server node n1 to start: dfgs.json, layout.json, udl_dlls.cfg, derecho.cfg
          |   |-- n2: include config for Cascade Client to start: derecho.cfg. (This node could also run as Cascade Server)
     |   |-- libconsole_printer_udl.so: compiled user defined logic funciton in the form of the dynamic linked library. As specified by udl_dlls.cfg, it can be accessed by all server nodes. The original code and implementation of this function is at directory: root/workspace/cascade/src/applications/tests/user_defined_logic/console_printer_udl.cpp
|   |-- python_udl
     |   |-- cfg
          |   |-- n0 ~ n2: config files to run node n0 ~ n2
          |   |-- libpython_udl.so: The pre-written user defined logic function to read the user defined logic in python and load to cascade server
     |   |-- python_udls: folder contains all the user defined udls written in python
                         (User can add/change the python implementation in this directory. To have the cascade server to load the user defined python function, adding the changes to dfgs.json files in root/example/python_udl/cfg/n0, root/example/python_udl/cfg/n1)
|   |-- ml_model_udl: similar to python_udl folder, contains code using 
     |   |-- cfg
          |   |-- n0 ~ n2: config files to run node n0 ~ n2
              |   |-- n2/client.py: client code to connect to the server nodes and send request to the system
     |   |-- python_udls: folder contains all the user defined udls written in python
          |   |-- resnet_udl.py : Python code that define a UDL with Resenet mode
          |   |-- imagenet_classes.txt : contains the categories used by image net model
```

# Run Example
In /root/example, there are three set of Cascade configurations(example/user_defined_logic, example/python_udl, example/ml_model_udl). example/user_defined_logic folder contains the example code of creating UDL(user-defined-logic) in C++; example/python_udl folder contains example of creating UDL(user-defined-logic) in Python code; example/ml_model_udl contains example of UDL(user-defined-logic) using Resnet model. All sets of example could run and be customized. In this documentation, we introdece steps to run example/ml_model_udl. Similar steps could be applied to the other ones

## Set Configuration
There are two sets of configuration files, one defines the server node, the other set defines the dataflow graph (including the user-defined-logics ). One can also customize and add more nodes to the /cfg if were to scale up to larger scale, by correctly putting the configuration files as defined below.

#### derecho.cfg & layout.json
Derecho.cfg and layout.json are the first set of configuration file, that defines the Cascade server node. Each server node folder contains a derecho.cfg, defining the network, layout, Derecho and Cascade server setting. You can find them under `root/example/ml_model_udl/cfg/n0`, `root/example/ml_model_udl/cfg/n1`, `root/example/ml_model_udl/cfg/n2`, `root/example/python_udl/cfg/n0`, ... `root/example/user_defined_logic/cfg/n0`, ...

The default setting defines all Cascade nodes on the same server using local host network interface: 127.0.0.1, and tcp network. One can edit this by specify the fields in derecho.cfg `leader_ip=` and `local_ip=` as needed by the applications. One can also specify the corresponding network provider under the field `provider = ` accordingly.

#### udl_dlls.cfg.tmp & dfgs.json.tmp
udl_dlls.cfg, and dfgs.json is the second set of configuration file, that defines the user-defined-logic(UDL) and their dependencies in the form of dataflow graphs(DFG). Each node require these two configuration in order to register and run the user defined logic(UDL). 

In the container image, we linked these two files to  `root/example/ml_model_udl/cfg/udl_dlls.cfg.tmp`, and `root/example/ml_model_udl/cfg/dfgs.json.tmp`. So that one only need to change these two configuration once at these two directory, and the corresponding files at `root/example/ml_model_udl/cfg/n0/udl_dlls.cfg`, `root/example/ml_model_udl/cfg/n1/udl_dlls.cfg` and `root/example/ml_model_udl/cfg/n2/udl_dlls.cfg` are changed at the same time.

## Start Cascade server 

To run Cascde server nodes and client node, it requires to be run in three different terminal windows. Tmux is a good tool to use to operate and view multiple terminals in one window. (https://github.com/tmux/tmux/wiki)

1. Start Cascade server node n0:
     In one terminal, direct to n0 config
      `cd root/example/ml_model_udl/cfg/n0`
     
     Remember to clear the log from previous run using the script `./clear_log.sh` before starting server node.

     Run cascade server node
      `cascade_server`
2. Start Cascade server node n1:
     In a different terminal, direct to n1 config
      `cd root/example/ml_model_udl/cfg/n1`

     Remember to clear the log from previous run using the script `./clear_log.sh` before starting server node.

     Run cascade server node
      `cascade_server`

## Start Cascade client

Directory of the client node configuration is at `root/example/ml_model_udl/cfg/n2`


### Three main ways to start cascade client
There are several ways to run cascade client. Here we introduce three of them: Command line client, C++ client and Python client.

First create a terminal, direct to n2 configuration directory.

##### 3.1. Command line client
Run `cascade_client` Then it will shows command line prompt.  

Run `help` could shows detailed command line options (https://github.com/Derecho-Project/cascade/tree/master/src/service)


##### 3.2. C++ Client

To trigger the user defined function, which in python_udls it defines two DFG(dataflow graphs). (The dataflow graph DFG definition can be viewed at root/example/python_udl/cfg/n0/dfgs.json file)

They could be triggered via '/' seprated prefix matching. By running: `put VCSS /console_printer/key0 value0 0 0`, you triggered the DFG with first pathname is '/console_printer'
By running: `put VCSS /word_count/mapper/key0 value0 0 0`, you triggered 'Word Count Python DFG, a demo of DFG without performance consideration'

There are three main ways to interact with(store to) Cascade Service that corresponde to three Subgroup types:
- VCSS: VolatileCascadeStoreWithStringKey
- PCSS: PersistentCascadeStoreWithStringKey
- TCSS: TriggerCascadeStoreWithStringKey


##### 3.3. Python client

Run `python` at in node n2, allows you to access the installed Cascade python support
More detail on the API of python client can be referenced from: https://github.com/Derecho-Project/cascade/tree/master/src/service/python

In the command prompt, you can import via: `from derecho.cascade.external_client import ServiceClientAPI`

and access the api via: `capi = ServiceClientAPI()`

This API, allows user to define python client program and directly run python client


### Example Client code 
In directory `root/example/ml_model_udl/cfg/n2` we wrote a sample python cliden code, that you can start with and customize to your applications.

You can start by running ```python client.py``` from `root/example/ml_model_udl/cfg/n2` directory.