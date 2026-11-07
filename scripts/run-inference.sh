#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

mkdir -p logs demo/infer

docker compose \
  -f compose.yaml \
  -f compose.shotstream.yaml \
  run --rm shotstream bash -lc '
    set -euo pipefail

    CUDA_VISIBLE_DEVICES=0 python3 Inference_Causal.py \
      --config_path ckpts/shotstream.yaml \
      --resume_ckpt ckpts/shotstream_merged.pt \
      --data_path demo/testdata/second_test.csv \
      --output_folder demo/infer \
      --multi_caption True \
      --seed 42
  ' 2>&1 | tee logs/second_test.log

find demo/infer -type f -name '*.mp4' -ls
