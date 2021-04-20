set +e
#!/bin/bash -x

# ROCm Version
ROCM_VERSION=4.0.1

# command to fetch submodules
git submodule update --init --recursive

mkdir data
cd data
mkdir wheel_py3_6
mkdir wheel_py3_7
mkdir wheel_py3_8
cd ..

# mkdir pytorch_source
# cd pytorch_source
# git clone --recursive https://github.com/pytorch/pytorch.git pytorch
# cd pytorch/.circleci/docker
# ./build.sh ubuntu18.04-rocm${ROCM_VERSION}-py3.7 -t rocm/pytorch:rocm${ROCM_VERSION}_ubuntu18.04_py3.7_pytorch
# ./build.sh ubuntu18.04-rocm${ROCM_VERSION}-py3.8 -t rocm/pytorch:rocm${ROCM_VERSION}_ubuntu18.04_py3.8_pytorch
# cd ../../../../
# rm -rf pytorch_source

# For python3.6 wheel
docker_image=rocm/pytorch:rocm${ROCM_VERSION}_ubuntu18.04_py3.6_pytorch
docker run -it --detach --privileged --network=host --device=/dev/kfd --device=/dev/dri --ipc="host" --pid="host" --shm-size 32G --group-add video --cap-add=SYS_PTRACE --security-opt seccomp=unconfined -v $(pwd):/audio -v $(pwd)/data:/data --name pytorch-rocm-audio-py36 --user root $docker_image

# uninstall previous versions
docker exec pytorch-rocm-audio-py36 bash -c "pip3 uninstall -y torch"
docker exec pytorch-rocm-audio-py36 bash -c "pip3 uninstall -y torchaudio"
docker exec pytorch-rocm-audio-py36 bash -c "pip3 install ninja"
docker exec pytorch-rocm-audio-py36 bash -c "pip3 install --pre torch -f https://download.pytorch.org/whl/nightly/rocm4.0.1/torch_nightly.html"

# build wheel
docker exec pytorch-rocm-audio-py36 bash -c "sed -i 's/name=\"torchaudio\"/name=\"torchaudio_rocm\"/g' /audio/setup.py"
docker exec pytorch-rocm-audio-py36 bash -c "sed -i 's/pytorch_package_dep = \x27torch\x27/pytorch_package_dep = \x27torch-rocm\x27/g' /audio/setup.py"
docker exec pytorch-rocm-audio-py36 bash -c "cd /audio && python3 setup.py clean"
docker exec pytorch-rocm-audio-py36 bash -c "pip3 install wheel"
docker exec pytorch-rocm-audio-py36 bash -c "cd /audio && USE_ROCM=1 BUILD_SOX=1 python setup.py bdist_wheel"

# install wheel
docker exec pytorch-rocm-audio-py36 bash -c "ls /audio/dist/"
docker exec pytorch-rocm-audio-py36 bash -c "cp /audio/dist/torch*.whl /data/wheel_py3_6/."
docker exec pytorch-rocm-audio-py36 bash -c "pip3 install --no-deps /audio/dist/torch*.whl"

# prep for tests
docker exec pytorch-rocm-audio-py36 bash -c "pip3 install ninja typing pytest scipy numpy parameterized"
docker exec pytorch-rocm-audio-py36 bash -c "pip3 install -r requirements.txt"
docker exec pytorch-rocm-audio-py36 bash -c "pip3 install scipy -U"
docker exec pytorch-rocm-audio-py36 bash -c 'export PATH=${PATH}:$(pwd)/third_party/kaldi/submodule/src/featbin/:$(pwd)/third_party/install/bin'
docker exec pytorch-rocm-audio-py36 bash -c "export KALDI_ROOT=$(pwd)"
docker exec pytorch-rocm-audio-py36 bash -c "export TORCHAUDIO_TEST_WITH_ROCM=1"

# run unit tests
docker exec pytorch-rocm-audio-py36 bash -c "cd /audio && pytest test -v 2>&1 | tee /data/audio_wheel_all_unit_tests_py36.log"

# clean up
docker exec pytorch-rocm-audio-py36 bash -c "cd /audio && python3 setup.py clean"
docker exec pytorch-rocm-audio-py36 bash -c "cd /audio && rm -rf build/ && rm -rf dist/"
docker stop pytorch-rocm-audio-py36

# ## For python3.7 wheel
# docker_image_py37=rocm/pytorch:rocm${ROCM_VERSION}_ubuntu18.04_py3.7_pytorch
# docker run -it --detach --privileged --network=host --device=/dev/kfd --device=/dev/dri --ipc="host" --pid="host" --shm-size 32G --group-add video --cap-add=SYS_PTRACE --security-opt seccomp=unconfined -v `pwd`:/audio -v `pwd`/data:/data --name pytorch-rocm-audio-py37 --user root $docker_image_py37
# docker exec pytorch-rocm-audio-py37 bash -c "pip3 uninstall -y torch"
# docker exec pytorch-rocm-audio-py37 bash -c "pip3 uninstall -y torchaudio"
# #docker exec pytorch-rocm-audio-py37 bash -c "pip3 install --pre torch -f https://download.pytorch.org/whl/nightly/rocm3.9/torch_nightly.html"
# docker exec pytorch-rocm-audio-py37 bash -c "pip3 install --pre torch -f https://download.pytorch.org/whl/nightly/rocm4.0.1/torch_nightly.html"
# #docker exec pytorch-rocm-audio-py37 bash -c "wget https://www.dropbox.com/s/99jxocjsbedjq0i/torch_rocm-1.7.0a0-cp37-cp37m-linux_x86_64.whl && pip3 install *.whl"

# docker exec pytorch-rocm-audio-py37 bash -c "pip3 uninstall -y torchaudio"
# docker exec pytorch-rocm-audio-py37 bash -c "cd /audio && python3 setup.py clean"
# docker exec pytorch-rocm-audio-py37 bash -c "pip3 install wheel"
# docker exec pytorch-rocm-audio-py37 bash -c "cd /audio && FORCE_CUDA=1 BUILD_VERSION=0.8.0 python3 setup.py bdist_wheel"
# docker exec pytorch-rocm-audio-py37 bash -c "cp /audio/dist/torch*.whl /data/wheel_py3_7/."
# docker exec pytorch-rocm-audio-py37 bash -c "pip3 uninstall -y torchaudio"
# docker exec pytorch-rocm-audio-py37 bash -c "pip3 install --no-deps /audio/dist/torch*.whl"
# #docker exec pytorch-rocm-audio-py37 bash -c "cd /audio && pytest test/ -v 2>&1 | tee /data/audio_unit_tests_py37.log"
# docker exec pytorch-rocm-audio-py37 bash -c "cd /audio && pytest test/test_ops.py -v 2>&1 | tee /data/audio_wheel_test_ops_unit_tests_py37.log"
# docker exec pytorch-rocm-audio-py37 bash -c "cd /audio && pytest test -v 2>&1 | tee /data/audio_wheel_unit_all_tests_py37.log"

# ## Clean up
# docker exec pytorch-rocm-audio-py37 bash -c "cd /audio && python3 setup.py clean"
# docker exec pytorch-rocm-audio-py37 bash -c "cd /audio && rm -rf build/ && rm -rf dist/"
# docker stop pytorch-rocm-audio-py37

# ## For python3.8 wheel
# docker_image_py38=rocm/pytorch:rocm${ROCM_VERSION}_ubuntu18.04_py3.8_pytorch
# docker run -it --detach --privileged --network=host --device=/dev/kfd --device=/dev/dri --ipc="host" --pid="host" --shm-size 32G --group-add video --cap-add=SYS_PTRACE --security-opt seccomp=unconfined -v `pwd`:/audio -v `pwd`/data:/data --name pytorch-rocm-audio-py38 --user root $docker_image_py38
# docker exec pytorch-rocm-audio-py38 bash -c "pip3 uninstall -y torch"
# docker exec pytorch-rocm-audio-py38 bash -c "pip3 uninstall -y torchaudio"
# #docker exec pytorch-rocm-audio-py38 bash -c "pip3 install --pre torch -f https://download.pytorch.org/whl/nightly/rocm3.9/torch_nightly.html"
# docker exec pytorch-rocm-audio-py38 bash -c "pip3 install --pre torch -f https://download.pytorch.org/whl/nightly/rocm4.0.1/torch_nightly.html"
# #docker exec pytorch-rocm-audio-py38 bash -c "wget https://www.dropbox.com/s/gnkso2fysad73dx/torch_rocm-1.7.0a0-cp38-cp38-linux_x86_64.whl && pip3 install *.whl"

# docker exec pytorch-rocm-audio-py38 bash -c "pip3 uninstall -y torchaudio"
# docker exec pytorch-rocm-audio-py38 bash -c "cd /audio && python3 setup.py clean"
# docker exec pytorch-rocm-audio-py38 bash -c "pip3 install wheel"
# docker exec pytorch-rocm-audio-py38 bash -c "cd /audio && FORCE_CUDA=1 BUILD_VERSION=0.8.0 python3 setup.py bdist_wheel"
# docker exec pytorch-rocm-audio-py38 bash -c "cp /audio/dist/torch*.whl /data/wheel_py3_8/."
# docker exec pytorch-rocm-audio-py38 bash -c "pip3 uninstall -y torchaudio"
# docker exec pytorch-rocm-audio-py38 bash -c "pip3 install --no-deps /audio/dist/torch*.whl"
# #docker exec pytorch-rocm-audio-py38 bash -c "cd /audio && pytest test/ -v 2>&1 | tee /data/audio_unit_tests_py38.log"
# docker exec pytorch-rocm-audio-py38 bash -c "cd /audio && pytest test/test_ops.py -v 2>&1 | tee /data/audio_wheel_test_ops_unit_tests_py38.log"
# docker exec pytorch-rocm-audio-py38 bash -c "cd /audio && pytest test -v 2>&1 | tee /data/audio_wheel_all_unit_tests_py38.log"

# docker stop pytorch-rocm-audio-py38
