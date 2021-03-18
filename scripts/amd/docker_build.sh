# print every command
# set -o xtrace

# set path
DOCKERFILE_PATH=scripts/amd/audio.Dockerfile

# get tag
DOCKERFILE_NAME=$(basename $DOCKERFILE_PATH)
DOCKERIMAGE_NAME=$(echo "$DOCKERFILE_NAME" | cut -f 1 -d '.')

# build docker
docker build -f $DOCKERFILE_PATH -t $DOCKERIMAGE_NAME .
