#!/bin/bash -x

set +e

# ROCm Version
# ROCM_VERSION=4.0.1

# command to fetch submodules
git submodule update --init --recursive

PYTHON_VERSION=(3.6)
#PYTHON_VERSION=(3.6 3.7 3.8)

for PY_VER in "${PYTHON_VERSION[@]}"; do

    # make wheel dir
    mkdir -p data
    cd data
    WHEEL_DIR=wheel_py${PY_VER//./_}
    mkdir -p $WHEEL_DIR
    cd ..

    # build pytorch docker
    if [ "${PY_VER}" != "3.6" ]; then
        mkdir -p pytorch_source
        cd pytorch_source
        git clone --recursive https://github.com/pytorch/pytorch.git pytorch
        cd pytorch/.circleci/docker
        ./build.sh ubuntu18.04-rocm${ROCM_VERSION}-py${PY_VER} -t rocm/pytorch:rocm${ROCM_VERSION}_ubuntu18.04_py${PY_VER}_pytorch
        cd ../../../../
    fi

    # get pytorch docker
    #DOCKER_IMAGE=rocm/pytorch:rocm${ROCM_VERSION}_ubuntu18.04_py${PY_VER}_pytorch
    DOCKER_IMAGE=rocm/pytorch:latest
    DOCKER_CONTAINER=pytorch-rocm-audio-py${PY_VER//./}
    docker run -it --detach --privileged --network=host --device=/dev/kfd --device=/dev/dri --ipc="host" --pid="host" --shm-size 32G --group-add video --cap-add=SYS_PTRACE --security-opt seccomp=unconfined \
        -v $(pwd):/audio -v $(pwd)/data:/data --name $DOCKER_CONTAINER --user root $DOCKER_IMAGE

    # uninstall previous versions
    docker exec $DOCKER_CONTAINER bash -c "pip3 uninstall -y torchaudio && \
        pip3 install ninja"

    # build wheel
    #docker exec $DOCKER_CONTAINER bash -c "sed -i 's/name=\"torchaudio\"/name=\"torchaudio_rocm\"/g' /audio/setup.py && \
     #   sed -i 's/pytorch_package_dep = \x27torch\x27/pytorch_package_dep = \x27torch-rocm\x27/g' /audio/setup.py && \
      #  cd /audio && python3 setup.py clean && \
       # pip3 install wheel && \
#        cd /audio && USE_ROCM=1 BUILD_SOX=1 python setup.py bdist_wheel"

    # install wheel
 #   docker exec $DOCKER_CONTAINER bash -c "ls /audio/dist/ && \
  #      cp /audio/dist/torch*.whl /data/$WHEEL_DIR/. && \
   #     pip3 install --no-deps /audio/dist/torch*.whl"
   
   # install audio
   docker exec $DOCKER_CONTAINER bash -c "sed -i 's/name=\"torchaudio\"/name=\"torchaudio_rocm\"/g' /audio/setup.py && \
        sed -i 's/pytorch_package_dep = \x27torch\x27/pytorch_package_dep = \x27torch-rocm\x27/g' /audio/setup.py && \
        cd /audio && python3 setup.py clean && \
        cd /audio && USE_ROCM=1 BUILD_SOX=1 python setup.py install"

    # prep for tests
    docker exec $DOCKER_CONTAINER bash -c "pip3 install ninja typing pytest scipy numpy parameterized && \
        pip3 install -r requirements.txt && \
        pip3 install scipy -U"

    # run unit tests
    docker exec $DOCKER_CONTAINER bash -c "export PATH=\${PATH}:/audio/third_party/kaldi/submodule/src/featbin/:/audio/third_party/install/bin && \
        export KALDI_ROOT=/audio && \
        export TORCHAUDIO_TEST_WITH_ROCM=1 && \
        cd /audio && pytest test \
        -v 2>&1 | tee /data/audio_wheel_all_unit_tests_py${PY_VER//./}.log"

    # clean up
    docker exec $DOCKER_CONTAINER bash -c "cd /audio && python3 setup.py clean && \
        cd /audio && rm -rf build/ && rm -rf dist/"
    docker stop $DOCKER_CONTAINER

done

