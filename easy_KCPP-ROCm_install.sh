#!/bin/bash
function countdown {
  local num=$1
  while [ $num -gt 0 ]; do
    printf "\rAbout to build KoboldCPP-ROCm in %s seconds..." $num
    sleep 1
    num=$((num - 1))
  done
  printf "\Building KoboldCPP...   \n"
}

if [ "$(basename "$PWD")" = "koboldcpp-rocm-dockerprepare" ]; then
  echo "Already inside 'koboldcpp-rocm-dockerprepare' directory."
else
  git clone https://github.com/Neresco/koboldcpp-rocm-dockerprepare.git -b main --depth 1 && \
  cd "koboldcpp-rocm-dockerprepare" || exit 1
fi

echo "Build will start shortly."
countdown 5

make clean && \
make LLAMA_HIPBLAS=1 -j4 \
exit 1
