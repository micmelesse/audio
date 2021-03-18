# alias drun='sudo docker run -it --network=host --runtime=nvidia --ipc=host'
alias drun='sudo docker run -it --network=host --ipc=host'

# WORK_DIR='-w /dockerx/audio'
WORK_DIR='-w /root/audio'

IMAGE_NAME=audio_nv

CONTAINER_ID=$(drun -d $WORK_DIR $VOLUMES $IMAGE_NAME)
echo "CONTAINER_ID: $CONTAINER_ID"
docker cp . $CONTAINER_ID:/root/audio
docker attach $CONTAINER_ID
docker stop $CONTAINER_ID
docker rm $CONTAINER_ID