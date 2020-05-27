# Melodic-base won't work becase we need access to tf publishers
FROM ros:melodic-robot

# Define the path for the directory we will be working in
ENV ROS_WS /opt/ros_lidar_x4_example

# Install catkin command line tools, git and clean apt cache
RUN apt-get update && apt-get install -y \
    python-catkin-tools \
    git \
&& rm -rf /var/lib/apt/lists/*

# Create working directory along with src subdir for ROS
RUN mkdir -p $ROS_WS/src

# Redefine working directory
WORKDIR $ROS_WS

# Clone master branch of YDLidar ROS repository into src directory
RUN git -C src clone -b master https://github.com/YDLIDAR/ydlidar_ros

# Install downloaded ROS packages / dependencies and clean apt cache again
RUN apt-get update && \
    rosdep update && rosdep install -y \
        --from-paths src/ydlidar_ros \
        --ignore-src \
    && rm -rf /var/lib/apt/lists/*

# Build YDLidar ROS package
RUN catkin config --extend /opt/ros/$ROS_DISTRO && catkin build ydlidar_ros

# Source package
RUN sed --in-place --expression \
      '$isource "$ROS_WS/devel/setup.bash"' \
      /ros_entrypoint.sh

# Default command when container launches
# This will immediately start the ROS lidar node and allow you to visualize in RVIZ
CMD ["roslaunch", "ydlidar_ros", "X4.launch"]