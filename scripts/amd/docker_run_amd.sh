alias drun='sudo docker run -it --rm --network=host --device=/dev/kfd --device=/dev/dri --ipc=host --shm-size 16G --group-add video --cap-add=SYS_PTRACE --security-opt seccomp=unconfined'
alias drun_nodevice='sudo docker run -it --rm --network=host --ipc=host --shm-size 16G --group-add video --cap-add=SYS_PTRACE --security-opt seccomp=unconfined'

VOLUMES="-v $HOME/dockerx:/dockerx -v /data:/data"

# WORK_DIR='/dockerx/audio'
WORK_DIR='/root/audio'

# IMAGE_NAME=rocm/pytorch
# IMAGE_NAME=rocm/pytorch:rocm4.0_ubuntu18.04_py3.6_pytorch
# IMAGE_NAME=rocm/pytorch:rocm4.0.1_ubuntu18.04_py3.6_pytorch
IMAGE_NAME=audio_amd
# IMAGE_NAME=rocm/pytorch:rocm4.0.1_ubuntu18.04_py3.7_pytorch

CONTAINER_ID=$(drun --user root -d -w $WORK_DIR $VOLUMES $IMAGE_NAME)
echo "CONTAINER_ID: $CONTAINER_ID"
docker cp . $CONTAINER_ID:$WORK_DIR
docker attach $CONTAINER_ID
docker stop $CONTAINER_ID
docker rm $CONTAINER_ID
