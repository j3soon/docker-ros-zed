# Docker image for Stereolabs' ZED Camera on ROS 1 Noetic

[<img src="https://img.shields.io/badge/dockerhub-image-important.svg?logo=docker">](https://hub.docker.com/r/j3soon/ros-noetic-zed/tags)

## Prerequisites

Hardware:

- A ZED camera

More information such as User Guide and Manual Installation steps can be found in [this post](https://j3soon.com/cheatsheets/stereolabs-zed-camera/).

## Installation

Clone the repo:

```sh
git clone https://github.com/j3soon/docker-ros-zed.git
cd docker-ros-zed
```

## ZED Tools

```sh
sudo apt-get update && sudo apt-get install -y docker.io docker-compose
# Connect and power on husky
docker-compose up -d
xhost +local:docker
docker exec -it ros-noetic-zed /ros_entrypoint.sh bash
# Inside the container
./tools/ZED_Explorer
# or run:
# ./tools/ZED_Depth_Viewer
# ./tools/ZED_Diagnostic
docker-compose down
```

The [pre-built docker images](https://hub.docker.com/r/j3soon/ros-noetic-zed/tags) will be pulled automatically.

> Functions such as ROS support and hot plugging are working properly in our preliminary tests. We will provide more detailed instructions in future updates.

## Build Docker Images Locally

- On amd64 machine:

  ```sh
  docker build -f Dockerfile -t j3soon/ros-noetic-zed:latest .
  ```

Currently, we do not support multiple architectures (e.g., ARM) yet.

## Tests

Last tested manually on 2023/11/10:

- Ubuntu 18.04.6 LTS (amd64) on Intel CPU

## Troubleshooting

- Most command failures can be resolved by simply re-running the command or reconnecting ZED.
- Exec into the container with bash for debugging:
  ```sh
  docker exec -it ros-noetic-zed /ros_entrypoint.sh bash
  ```
- See [this post](https://j3soon.com/cheatsheets/robot-operating-system/) for troubleshooting ROS.
- See [this post](https://j3soon.com/cheatsheets/stereolabs-zed-camera/) for troubleshooting ZED.
