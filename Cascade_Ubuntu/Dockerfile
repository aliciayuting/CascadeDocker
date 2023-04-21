FROM songweijia/devel:cascade.generic.ubuntu22.04

LABEL maintainer="yy354@cornell.edu"

RUN apt update
RUN apt upgrade -y --fix-missing

ENV LOCAL_OPT=/root/opt-dev
ENV C_INCLUDE_PATH=$LOCAL_OPT/include
ENV CPLUS_INCLUDE_PATH=$LOCAL_OPT/include
ENV CMAKE_PREFIX_PATH=$LOCAL_OPT/
ENV LIBRARY_PATH=$LOCAL_OPT/lib/:/usr/local/lib/
ENV LD_LIBRARY_PATH=$LOCAL_OPT/lib/:/usr/local/lib/
ENV JAVA_HOME=/usr/lib/jvm/java-16-openjdk-amd64/

# 1. Clean the previously built Derecho&Cascade libraries
RUN rm -rf /root/opt-dev/include/derecho
RUN rm -rf /root/opt-dev/include/cascade
RUN rm -rf /root/opt-dev/lib/libderecho*
RUN rm -rf /root/opt-dev/lib/libcascade*
RUN rm -rf /root/opt-dev/lib/cmake/cascade
RUN rm -rf /root/opt-dev/lib/cmake/derecho
RUN rm -rf /root/opt-dev/bin/cascade*
RUN rm -rf /root/opt-dev/share/derecho

# 2. Build latest Derecho library
WORKDIR /root/workspace/derecho
RUN mv /root/workspace/derecho/scripts/build/build.sh /root/workspace/
RUN git fetch --all && git reset --hard origin/master
RUN git checkout df81fa4888861d796a1e20e459da7ff36737e40e
RUN mv /root/workspace/build.sh /root/workspace/derecho/scripts/build/
RUN rm -rf /root/workspace/derecho/build-Release
RUN ./build.sh Release
WORKDIR /root/workspace/derecho/build-Release
RUN make -j32
RUN make install

# 3. Build latest Cascade library
WORKDIR /root/workspace/cascade
RUN git fetch --all && git reset --hard origin/master
RUN git checkout 854f08c268ca9af50580593c54b75d566b94dd92

# 3.1 install dependency
RUN apt-get install ragel
WORKDIR /root/workspace/cascade/scripts/prerequisites
RUN ./install-hyperscan.sh
RUN apt install python3-dev
RUN pip3 install numpy
RUN pip3 install build pybind11

# 3.2 install Cascade with Python dependency
WORKDIR /root/workspace/cascade
COPY ./build.sh /root/workspace/cascade/
RUN chmod +x /root/workspace/cascade/build.sh
RUN rm -rf build-Release
RUN ./build.sh Release
RUN apt-get update -y
RUN apt-get install -y python3.10-venv
WORKDIR /root/workspace/cascade/build-Release
RUN cmake -Dpybind11_DIR=/usr/local/lib/python3.10/dist-packages/pybind11/share/cmake/pybind11/ ..
RUN make -j32
RUN make install
# # build cascade_py
WORKDIR /root/workspace/cascade/build-Release/src/service/python/dist
RUN pip3 install derecho.cascade-1.0rc0-py3-none-any.whl 


# 3.3 build python udl
WORKDIR /root/workspace/cascade/src/applications
ARG GITHUB_TOKEN
RUN git clone https://$GITHUB_TOKEN@github.com/Derecho-Project/cascade-demos.git 
WORKDIR /root/workspace/cascade/src/applications/cascade-demos
RUN git checkout collision_prediction
# 3.3.1 temp fix in code due to compilation error 
WORKDIR /root/workspace/cascade/src/applications/cascade-demos/udl_zoo/python
RUN sed -i '18d' ./python_udl.cpp
RUN sed -i '18i\#define PYTHONLIB   \"libpython_udl.so\" ' ./python_udl.cpp

# 3.3.2 Add this director to CMakeLists to compile
WORKDIR /root/workspace/cascade/
RUN sed -i '107i\add_subdirectory(src/applications/cascade-demos/udl_zoo/python)' ./CMakeLists.txt
# 3.3.3 rebuild Cascade with udl
WORKDIR /root/workspace/cascade/build-Release
RUN make -j32
RUN make install

ENV PATH=$PATH:/root/opt-dev/bin

# 3.4 Copy example cfg
WORKDIR /root
RUN mkdir example
RUN cp -r workspace/cascade/build-Release/src/applications/tests/user_defined_logic ./example
RUN rm -rf ./example/user_defined_logic/CMakeFiles
RUN rm ./example/user_defined_logic/Makefile
RUN rm ./example/user_defined_logic/cmake_install.cmake
RUN mkdir example/python_udl
RUN cp -r workspace/cascade/build-Release/src/applications/cascade-demos/udl_zoo/python/* ./example/python_udl
RUN rm -rf ./example/python_udl/CMakeFiles
RUN rm ./example/python_udl/Makefile
RUN rm -rf ./example/python_udl/*.cmake
RUN rm -rf ./example/python_udl/*.tmp
RUN rm ./example/python_udl/dfgs.json.tmp.multiapp