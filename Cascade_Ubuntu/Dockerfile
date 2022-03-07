FROM songweijia/devel:mlnxofed5.3-cuda11.03-ubuntu20.04

LABEL maintainer="yw2399@cornell.edu"
EXPOSE 22/tcp
RUN apt update
RUN apt upgrade -y --fix-missing

ENV LOCAL_OPT=/root/opt-dev
ENV C_INCLUDE_PATH=$LOCAL_OPT/include
ENV CPLUS_INCLUDE_PATH=$LOCAL_OPT/include
ENV CMAKE_PREFIX_PATH=$LOCAL_OPT/
ENV LIBRARY_PATH=$LOCAL_OPT/lib/:/usr/local/lib/
ENV LD_LIBRARY_PATH=$LOCAL_OPT/lib/:/usr/local/lib/
ENV JAVA_HOME=/usr/lib/jvm/java-16-openjdk-amd64/

# install cascade prerequisites
RUN mkdir -p /root/workspace/prerequisites
# 1.nlohmann
WORKDIR /root/workspace/prerequisites
RUN git clone https://github.com/nlohmann/json.git
WORKDIR /root/workspace/prerequisites/json
RUN git checkout tags/v3.9.1
RUN mkdir /root/workspace/prerequisites/json/build
WORKDIR /root/workspace/prerequisites/json/build
RUN cmake -DCMAKE_INSTALL_PREFIX=/usr/local/ ..
RUN make -j
RUN make install
# 2.fuse
RUN apt-get -y install meson udev --fix-missing
WORKDIR /root/workspace/prerequisites
RUN git clone https://github.com/libfuse/libfuse.git
WORKDIR /root/workspace/prerequisites/libfuse
RUN git checkout tags/fuse-3.9.4
RUN mkdir build
WORKDIR /root/workspace/prerequisites/libfuse/build
RUN meson --prefix=/usr/local ..
RUN ninja
RUN ninja install
# 3.boolinq
RUN mkdir /usr/local/include/boolinq
COPY boolinq.h /usr/local/include/boolinq/
# 4.pybind11
RUN pip3 install build pybind11
# PYTHON dependency
RUN apt install python3.8-venv
# 5.ssh
RUN apt-get install ssh
RUN ssh-keygen -A
RUN service ssh start
COPY id_rsa.pub /root/.ssh/authorized_keys
# 6. java
RUN apt install -y openjdk-16-jdk-headless --fix-missing

# install derecho and its prerequisites
RUN apt-get -y install libspdlog-dev libssl-dev
#RUN apt-get install -y libfabric-dev
WORKDIR /root/workspace
RUN git clone https://github.com/Derecho-Project/derecho.git
WORKDIR /root/workspace/derecho
RUN git fetch && git checkout for_cascade_get_api && git checkout 0ac2fb535f372cb964c823baf1391b1e2f2241dd && git pull
WORKDIR /root/workspace/derecho/scripts/prerequisites
RUN ./install-libfabric.sh
RUN ./install-mutils.sh
RUN ./install-mutils-tasks.sh
RUN ./install-mutils-containers.sh
RUN ./install-json.sh
WORKDIR /root/workspace/derecho
COPY ./build.sh /root/workspace/derecho/scripts/build/
RUN chmod +x /root/workspace/derecho/scripts/build/build.sh
USER root
RUN ./build.sh Release
WORKDIR /root/workspace/derecho/build-Release
RUN make install
WORKDIR /root/workspace/derecho/
RUN ln -s build-Release/compile_commands.json
#RUN sysctl -w vm.overcommit_memory=1

# cascade
WORKDIR /root/workspace
RUN git clone https://github.com/Derecho-Project/cascade.git
WORKDIR /root/workspace/cascade
RUN git fetch && git checkout v1.0rc && git pull

# Reconfigure the cfg for smaller required memory to run Cascade
RUN cp /root/workspace/cascade/src/applications/standalone/kvs_client/cfg/n0/derecho.cfg /root/workspace/cascade/src/service/cfg/n0/
RUN cp /root/workspace/cascade/src/applications/standalone/kvs_client/cfg/n1/derecho.cfg /root/workspace/cascade/src/service/cfg/n1/
RUN cp /root/workspace/cascade/src/applications/standalone/kvs_client/cfg/n2/derecho.cfg /root/workspace/cascade/src/service/cfg/n2/
RUN cp /root/workspace/cascade/src/applications/standalone/kvs_client/cfg/layout.json /root/workspace/cascade/src/service/cfg/
RUN rm -rf /root/workspace/cascade/src/service/cfg/n3/
RUN rm -rf /root/workspace/cascade/src/service/cfg/n4/
RUN rm -rf /root/workspace/cascade/src/service/cfg/n5/
RUN rm -rf /root/workspace/cascade/src/service/cfg/n6/

WORKDIR /root/workspace/cascade
WORKDIR /root/workspace/cascade/scripts/prerequisites
RUN ./install-rpclib.sh 
#RUN ./install-mxnet-src.sh
WORKDIR /root/workspace/cascade/
RUN ./build.sh Release
WORKDIR /root/workspace/cascade/build-Release
RUN cmake -Dpybind11_DIR=/usr/local/lib/python3.8/dist-packages/pybind11/share/cmake/pybind11 ..
RUN make install



# entry point
WORKDIR /root