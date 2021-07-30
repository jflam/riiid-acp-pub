docker run --ipc=host --gpus=all -p 8888:8888 --mount type=bind,source="$(pwd)"/,target=/root/repo --rm -it jflam/kaggle /bin/bash
