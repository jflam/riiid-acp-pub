FROM nvcr.io/nvidia/pytorch:21.06-py3

ARG CONTAINER_USER=jlam
ARG CONTAINER_USER_ID=1000

# Create CONTAINER_USER and their home directory
RUN useradd -m -u ${CONTAINER_USER_ID} ${CONTAINER_USER}

# Activate conda as CONTAINER_USER
USER ${CONTAINER_USER}
RUN conda init && \
    exec bash

WORKDIR /home/${CONTAINER_USER}/repo
CMD [ "jupyter", "notebook", "--no-browser", "--ip", "0.0.0.0" ]