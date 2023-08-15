# Overview
Cascade is a C++17 cloud application framework powered by optimized RDMA data paths. It provides a K/V API for data manipulation in distributed memory and persistent storage. Besides the K/V API, Cascade allows injecting logic on the data paths for low-latency application. 

This docker image is built to support the all of the following functionalties.

- Command line client API interacts with Cascade Servers

- Python client API interacts with Cascade Servers

- User Defined Logic to the data path

     - User could define function/logic in C++ as a dynamic linked library(.so file) to preload to Cascade Server 

     - User could define function/logic in Python code, then the pre-written python_udl.so file will load the Python code to Cascade Server address space to call the Python function user defined


# Directories

- opt-dev: contains the pre-built Cascade&Derecho binaries and libraries

- workspace: contains the Cascade and Derecho code, this directory is mainly used for Cascade&Derecho development 

```bash
.
|-- example:
|   |-- user_defined_logic: copied from the built folder in ~/workspace/cascade/src/applications/tests/user_defined_logic. 
     |   |-- console_printer_cfg: contains the cascade servers & client configs
          |   |-- n0: include 4 configs for Cascade Server node n0 to start: dfgs.json, layout.json, udl_dlls.cfg, derecho.cfg
          |   |-- n1: include 4 configs for Cascade Server node n1 to start: dfgs.json, layout.json, udl_dlls.cfg, derecho.cfg
          |   |-- n2: include config for Cascade Client to start: derecho.cfg. (This node could also run as Cascade Server, in which case, all 4 configs in this directory are used)
     |   |-- libconsole_printer_udl.so: compiled user defined logic funciton in the form of the dynamic linked library. The original code and implementation of this function is at directory: ~/workspace/cascade/src/applications/tests/user_defined_logic/console_printer_udl.cpp
|   |-- python_udl: copied from the built folder in ~/workspace/cascade/src/applications/cascade-demos/udl_zoo/python, where the executables get compiled
     |   |-- cfg
          |   |-- n0 ~ n2: config files to run node n0 ~ n2
          |   |-- libpython_udl.so: The pre-written user defined logic function to read the user defined logic in python and load to cascade server
     |   |-- python_udls: folder contains all the user defined udls written in python
                         (User can add/change the python implementation in this directory. To have the cascade server to load the user defined python function, adding the changes to dfgs.json files in ~/example/python_udl/cfg/n0, ~/example/python_udl/cfg/n1)
```

# Run Example
In /root/example, there are two set of Cascade configurations(user_defined_logic, python_udl), either one could run Cascade Servers and Client.

To run Cascde server nodes and client node, it requires to be run in three different terminal windows. Tmux is a good tool to use to operate and view multiple terminals in one window. (https://github.com/tmux/tmux/wiki)

1. Start Cascade server node n0:
     In one terminal, direct to n0 config
      `cd ~/example/python_udl/cfg/n0`
     Run cascade server node
      `cascade_server`
2. Start Cascade server node n1:
     In a different terminal, direct to n1 config
      `cd ~/example/python_udl/cfg/n1`
     Run cascade server node
      `cascade_server`
3. Start Cascade client node:
     In another terminal, direct to n2 config

There are several ways to run cascade client.

3.1. Command line client
Run `cascade_client` Then it will shows command line prompt.  

Run `help` could shows detailed command line options (https://github.com/Derecho-Project/cascade/tree/master/src/service)



3.2. Trigger User Defined Logic

To trigger the user defined function, which in python_udls it defines two DFG(dataflow graphs). (The dataflow graph DFG definition can be viewed at ~/example/python_udl/cfg/n0/dfgs.json file)

They could be triggered via '/' seprated prefix matching. By running: `put VCSS /console_printer/key0 value0 0 0`, you triggered the DFG with first pathname is '/console_printer'
By running: `put VCSS /word_count/mapper/key0 value0 0 0`, you triggered 'Word Count Python DFG, a demo of DFG without performance consideration'

There are three main ways to interact with(store to) Cascade Service that corresponde to three Subgroup types:
- VCSS: VolatileCascadeStoreWithStringKey
- PCSS: PersistentCascadeStoreWithStringKey
- TCSS: TriggerCascadeStoreWithStringKey


3.3. Python client

Run `python` at in node n2, allows you to access the installed Cascade python support

In the command prompt, you can import via: `from derecho.cascade.external_client import ServiceClientAPI`

and access the api via: `capi = ServiceClientAPI()`

This API, allows user to define python client program and directly run python client

