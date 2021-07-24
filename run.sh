docker run --gpus all -p 8888:8888 --mount type=bind,source="$(pwd)"/,target=/home/jlam/repo --rm -it jflam/kaggle
