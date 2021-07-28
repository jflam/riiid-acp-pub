FROM nvcr.io/nvidia/pytorch:21.06-py3

ARG CONTAINER_USER=jlam
ARG CONTAINER_USER_ID=1000

# Create CONTAINER_USER and their home directory
RUN useradd -m -u ${CONTAINER_USER_ID} ${CONTAINER_USER}

# Activate conda as CONTAINER_USER
USER ${CONTAINER_USER}
RUN conda init && \
    exec bash

# Copy environment.yml into the container and create the environment
WORKDIR /home/${CONTAINER_USER}
COPY --chown=${CONTAINER_USER}:${CONTAINER_USER} environment.yml \
     /home/${CONTAINER_USER}/environment.yml
RUN conda env create -v -f environment.yml

WORKDIR /home/${CONTAINER_USER}/repo
CMD [ "jupyter", "notebook", "--no-browser", "--ip", "0.0.0.0" ]