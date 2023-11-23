# We choose Ubuntu 20.04 since ROS Noetic targets Ubuntu 20.04.
# Ref: http://wiki.ros.org/noetic
# If you want to change the CUDA version, see the following link.
# Ref: https://hub.docker.com/r/nvidia/cudagl
ARG UBUNTU_RELEASE_YEAR=20
ARG CUDA_MAJOR=11
ARG CUDA_MINOR=4
ARG CUDA_PATCH=2
FROM nvidia/cudagl:${CUDA_MAJOR}.${CUDA_MINOR}.${CUDA_PATCH}-devel-ubuntu${UBUNTU_RELEASE_YEAR}.04

# ====================
# Install ZED SDK
# ====================
# We choose ZED SDK 4.0.

# Run the commands based on `stereolabs/zed:4.0-gl-devel-cuda11.4-ubuntu20.04`
# Ref: https://hub.docker.com/r/stereolabs/zed/tags?page=1&name=4.0-gl-devel-cuda11.4-ubuntu20.04
# Ref: https://github.com/stereolabs/zed-docker/blob/fde3fe833859eb78831b0cc4c0a119b745f6ff62/4.X/ubuntu/gl-devel/Dockerfile
# The commands below are slightly modified to fit our need

# We do not choose to use the docker image provided by `stereolabs/zed`, since we want to use the latest CUDA patch.

ARG UBUNTU_RELEASE_YEAR
ARG CUDA_MAJOR
ARG CUDA_MINOR
ARG CUDA_PATCH
ARG ZED_SDK_MAJOR=4
ARG ZED_SDK_MINOR=0

ENV NVIDIA_DRIVER_CAPABILITIES \
    ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}compute,video,utility,graphics

RUN echo "Europe/Paris" > /etc/localtime ; echo "CUDA Version ${CUDA_MAJOR}.${CUDA_MINOR}.${CUDA_PATCH}" > /usr/local/cuda/version.txt

# Setup the ZED SDK
RUN apt-get update -y || true ; apt-get install --no-install-recommends lsb-release wget less udev zstd sudo build-essential cmake python3 python3-pip libpng-dev libgomp1 -y ; \
    #python3 -m pip install --upgrade pip ; \
    python3 -m pip install numpy opencv-python pyopengl ; \
    wget -q -O ZED_SDK_Linux_Ubuntu${UBUNTU_RELEASE_YEAR}.run https://download.stereolabs.com/zedsdk/${ZED_SDK_MAJOR}.${ZED_SDK_MINOR}/cu${CUDA_MAJOR}${CUDA_MINOR%.*}/ubuntu${UBUNTU_RELEASE_YEAR} && \
    chmod +x ZED_SDK_Linux_Ubuntu${UBUNTU_RELEASE_YEAR}.run ; ./ZED_SDK_Linux_Ubuntu${UBUNTU_RELEASE_YEAR}.run silent skip_cuda && \
    ln -sf /lib/x86_64-linux-gnu/libusb-1.0.so.0 /usr/lib/x86_64-linux-gnu/libusb-1.0.so && \
    rm ZED_SDK_Linux_Ubuntu${UBUNTU_RELEASE_YEAR}.run && \
    rm -rf /var/lib/apt/lists/*

# Make some tools happy
RUN mkdir -p /root/Documents/ZED/

WORKDIR /usr/local/zed/

# ====================
# Install ROS Noetic
# ====================
# We do not choose to use the docker image provided by `stereolabs/zed`,
# since it is not maintained after ZED SDK 3.4
# Ref: https://www.stereolabs.com/docs/docker/using-ros/
# Ref: https://hub.docker.com/r/stereolabs/zed/tags?page=1&name=ros-devel-cuda11
# Run the commands based the following links
# Ref: https://github.com/j3soon/docker-ros-noetic-desktop-full
# Ref: https://github.com/osrf/docker_images/tree/1c1fc8d922d3ca45e1712072ef9e39052f29cc63/ros/noetic/ubuntu/focal

# ros-core
# Ref: https://github.com/osrf/docker_images/blob/master/ros/noetic/ubuntu/focal/ros-core/Dockerfile
# setup timezone
RUN echo 'Etc/UTC' > /etc/timezone && \
    # ln -s /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
    apt-get update && \
    apt-get install -q -y --no-install-recommends tzdata && \
    rm -rf /var/lib/apt/lists/*
# install packages
RUN apt-get update && apt-get install -q -y --no-install-recommends \
    dirmngr \
    gnupg2 \
    && rm -rf /var/lib/apt/lists/*
# setup sources.list
RUN echo "deb http://packages.ros.org/ros/ubuntu focal main" > /etc/apt/sources.list.d/ros1-latest.list
# setup keys
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
# setup environment
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV ROS_DISTRO noetic
# install ros packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-noetic-ros-core=1.5.0-1* \
    && rm -rf /var/lib/apt/lists/*

# ros-base
# Ref: https://github.com/osrf/docker_images/blob/master/ros/noetic/ubuntu/focal/ros-base/Dockerfile
# install bootstrap tools
RUN apt-get update && apt-get install --no-install-recommends -y \
    build-essential \
    python3-rosdep \
    python3-rosinstall \
    python3-vcstools \
    && rm -rf /var/lib/apt/lists/*
# bootstrap rosdep
RUN rosdep init && \
  rosdep update --rosdistro $ROS_DISTRO
# install ros packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-noetic-ros-base=1.5.0-1* \
    && rm -rf /var/lib/apt/lists/*

# ros-robot
# Ref: https://github.com/osrf/docker_images/blob/master/ros/noetic/ubuntu/focal/robot/Dockerfile
# install ros packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-noetic-robot=1.5.0-1* \
    && rm -rf /var/lib/apt/lists/*

# ros-desktop
# Ref: https://github.com/osrf/docker_images/blob/master/ros/noetic/ubuntu/focal/desktop/Dockerfile
# install ros packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-noetic-desktop=1.5.0-1* \
    && rm -rf /var/lib/apt/lists/*

# ros-desktop-full
# Ref: https://github.com/osrf/docker_images/blob/master/ros/noetic/ubuntu/focal/desktop-full/Dockerfile
# install ros packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-noetic-desktop-full=1.5.0-1* \
    && rm -rf /var/lib/apt/lists/*

# ros-core
# Ref: https://github.com/osrf/docker_images/blob/master/ros/noetic/ubuntu/focal/ros-core/Dockerfile
# setup entrypoint
COPY ./thirdparty/ros_entrypoint.sh /
ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]

# ====================
# Custom Commands
# ====================

# Install common tools
RUN apt-get update && apt-get install -y git vim tmux \
    && rm -rf /var/lib/apt/lists/*

# Ref: https://github.com/stereolabs/zed-ros-wrapper#build-the-repository
# The commands below are slightly modified to fit our need

# RUN mkdir -p ~/catkin_ws/src \
#     && cd ~/catkin_ws/src \
#     && git clone https://github.com/stereolabs/zed-ros-wrapper.git \
#     && cd zed-ros-wrapper \
#     && git reset --hard 71eb2bb434f059e17191503b707267938f5a1b7f \
#     && git pull --recurse-submodules \
#     && cd ../../ \
#     && . /opt/ros/noetic/setup.sh \
#     && rosdep install --from-paths src --ignore-src -r -y \
#     && catkin_make -DCMAKE_BUILD_TYPE=Release \
#     && . ./devel/setup.sh
