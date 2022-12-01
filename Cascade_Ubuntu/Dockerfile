FROM songweijia/devel:cascade.generic.ubuntu22.04

LABEL maintainer="yy354@cornell.edu"
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

COPY ./clean_build.sh /root/
RUN chmod +x /root/clean_build.sh


# py_cascade
# 1. dependency install
# 1.1 PYTHON dependency
RUN apt-get update -y
RUN apt-get install -y python3.10-venv
# 1.2 pybind11
# below command install pybind11 to /usr/local/lib/python3.10/dist-packages
RUN pip3 install build pybind11

# 2. link dependency in cmake
COPY ./build.sh /root/workspace/cascade/
RUN chmod +x /root/workspace/cascade/build.sh
WORKDIR /root/workspace/cascade/
RUN ./build.sh Release
WORKDIR /root/workspace/cascade/build-Release
RUN cmake -Dpybind11_DIR=/usr/local/lib/python3.10/dist-packages/pybind11/share/cmake/pybind11/ ..
# RUN make -j --debug
# RUN make install

# # 3. 
# # # build cascade_py
# WORKDIR /root/workspace/cascade/build-Release/src/service/python/dist
# RUN pip3 install derecho.cascade-1.0rc0-py3-none-any.whl 


# entry point
WORKDIR /root
