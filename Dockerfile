FROM nvidia/cuda:11.7.1-cudnn8-devel-ubuntu22.04


CMD ["/bin/bash"]

# Args for setting up non-root users, example command to use your own user:
# docker build -t found \
#   --build-arg USERID=$(id -u) \
#   --build-arg GROUPID=$(id -g) \
#   --build-arg USERNAME=$(whoami) \
#   --build-arg HOMEDIR=${HOME} .

#To run
#  docker run -it --name found \
#  --privileged \
#  --network=host \
#  --gpus=all \
#  --ipc=host \
#  -e DISPLAY=$DISPLAY \
#  -v /tmp/.X11-unix:/tmp/.X11-unix \
#  -v ~/CVPR/FOUND:~/FOUND:rw \
#  found
ARG GROUPID=0
ARG USERID=0
ARG USERNAME=root
ARG HOMEDIR=/root

RUN if [ ${GROUPID} -ne 0 ]; then addgroup --gid ${GROUPID} ${USERNAME}; fi \
  && if [ ${USERID} -ne 0 ]; then adduser --disabled-password --gecos '' --uid ${USERID} --gid ${GROUPID} ${USERNAME}; fi

# Default number of threads for make build
ARG NUMPROC=12

ENV DEBIAN_FRONTEND=noninteractive

## Switch to root to install dependencies
USER 0:0

## Dependencies
RUN apt update && apt upgrade -q -y
RUN apt update && apt install -q -y cmake git build-essential lsb-release curl gnupg2
RUN apt update && apt install -q -y libboost-all-dev libglib2.0-0
RUN apt update && apt install -q -y libx11-dev libxrandr-dev libxinerama-dev libxcursor-dev libxi-dev
RUN apt update && apt install -q -y freeglut3-dev

RUN apt update && apt install -q -y python3 python3-distutils python3-pip python-is-python3

## Switch to specified user to create directories
USER ${USERID}:${GROUPID}

RUN curl -o $HOMEDIR/found_requirements.txt https://raw.githubusercontent.com/a-krawciw/FOUND/main/requirements.txt

USER 0:0
RUN pip3 install --upgrade pip
RUN pip3 install setuptools
RUN pip3 install torch torchvision torchaudio
RUN pip3 install -r $HOMEDIR/found_requirements.txt
RUN pip3 install numpy scikit-learn matplotlib PyYAML
RUN pip3 install imageio
RUN pip3 install jupyter


# Install nano
RUN apt update && apt install -q -y nano

## Switch to specified user
USER ${USERID}:${GROUPID}

