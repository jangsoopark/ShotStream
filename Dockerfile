
FROM nvidia/cuda:12.8.1-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV CUDA_HOME=/usr/local/cuda
ENV PATH="${CUDA_HOME}/bin:${PATH}"
ENV PYTHONUNBUFFERED=1
ENV PIP_NO_CACHE_DIR=1
ENV MAX_JOBS=4

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-dev \
    build-essential \
    git \
    ninja-build \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --upgrade \
    pip setuptools wheel packaging psutil ninja

RUN python3 -m pip install \
    torch==2.8.0 \
    torchvision==0.23.0 \
    torchaudio==2.8.0 \
    --index-url https://download.pytorch.org/whl/cu128

RUN python3 -m pip install \
    flash-attn==2.8.3.post2 \
    --no-build-isolation

WORKDIR /workspace

CMD ["/bin/bash"]
