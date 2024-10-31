FROM ubuntu:22.04 as stage1
WORKDIR /app

RUN mkdir tmp
RUN apt update
RUN apt install -yq wget python3 python-is-python3 tree nano radeontop vim curl bzip2 git cmake make gcc
#python3 is optional i have added is for testing to make the start command work
#python-is-python3 is helpful for ease of use
RUN apt install -yq "libstdc++-12-dev"
RUN wget -O tmp/rocm.deb https://repo.radeon.com/amdgpu-install/6.2.2/ubuntu/jammy/amdgpu-install_6.2.60202-1_all.deb  
RUN apt install -yq "./tmp/rocm.deb"

FROM stage1 as stage2
RUN amdgpu-install --usecase=hip,rocm --no-dkms -yq
EXPOSE 5001
CMD ["/bin/bash"]

# RDNA2 GPU Override RX 6600 - 6900 XT
# ENV HSA_OVERRIDE_GFX_VERSION=11.0.0 for RDNA3 RX 7600 - 7900XTX
ENV HSA_OVERRIDE_GFX_VERSION=10.3.0
RUN amdgpu-install --usecase=hip,rocm --no-dkms -yq

RUN <<EOF
	cd /app
	git clone https://github.com/YellowRoseCx/koboldcpp-rocm.git -b main --depth 1
EOF

WORKDIR /app/koboldcpp-rocm
# Docker Build Command:
# Go into the directory where kobold-rocm is cloned (or the Dockerfile is)
# "sudo docker build -t kobold:latest ." or
# "sudo docker buildx build --no-cache -t kobold:latest ."

#Docker run command:
# sudo docker run -p 5001:5001 --device /dev/kfd --device /dev/dri --mount type=bind,source="$HOME"/models,target=/models kobold:latest

#following needs to be run again in Container to prevent start errors from koboldcpp
# /app/koboldcpp-rocm
# make clean
# make LLAMA_HIPBLAS=1 -j4 or
# make LLAMA_HIPBLAS=1 LLAMA_VULKAN=1 -j4 (with LLAMA_VULKAN=1 it fails sometimes....)

#Start in Container with 
# "python koboldcpp.py --config /models/config.json" (Without the"")
