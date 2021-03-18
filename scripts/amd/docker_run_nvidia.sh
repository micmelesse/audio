alias drun='sudo docker run -it --network=host --runtime=nvidia --ipc=host -v $HOME/dockerx:/dockerx -v /data:/data'

WORK_DIR='/dockerx/audio'

drun -w $WORK_DIR audio_nv