# ShotStream Docker inference environment

This is a **starting setup**, not a confirmed run of ShotStream inference.

Prerequisites: existing `compose.yaml` and a locally built image named `shotstream:cu128` (CUDA 12.8.1, PyTorch 2.8.0+cu128, FlashAttention 2.8.3.post2). NVIDIA Container Toolkit must be updated and actual PyTorch CUDA compute must pass.

Copy `Dockerfile.shotstream`, `compose.shotstream.yaml`, `requirements.inference.txt`, and `check_dependencies.py` alongside your existing `Dockerfile`, `compose.yaml` and `requirements.txt`. They do not overwrite the existing files. If replacing an earlier version of this companion package, update `Dockerfile.shotstream` and add `check_dependencies.py`.

```bash
cd /mnt/d/01.Project/long-form/ShotStream
mkdir -p wan_models ckpts demo/infer

docker image inspect shotstream:cu128 >/dev/null

docker compose -f compose.yaml -f compose.shotstream.yaml config

docker compose -f compose.yaml -f compose.shotstream.yaml build

docker compose -f compose.yaml -f compose.shotstream.yaml run --rm shotstream \
  python3 -c 'import torch; x=torch.ones(4,device="cuda"); print(x); import flash_attn; print(flash_attn.__version__)'

docker compose -f compose.yaml -f compose.shotstream.yaml run --rm shotstream \
  python3 -c 'from pipeline import CausalInferenceArPipeline; print("pipeline import: OK")'
```

Official WAN model files must be nested in `wan_models/Wan2.1-T2V-1.3B/` (the reference code uses that path):

```bash
docker compose -f compose.yaml -f compose.shotstream.yaml run --rm shotstream \
  hf download Wan-AI/Wan2.1-T2V-1.3B --local-dir wan_models/Wan2.1-T2V-1.3B
```

Only download the three ShotStream files required for inference:

```bash
docker compose -f compose.yaml -f compose.shotstream.yaml run --rm shotstream \
  hf download KlingTeam/ShotStream shotstream.yaml default_config.yaml shotstream_merged.pt --local-dir ckpts
```

Only after GPU memory/offloading adaptations (8 GB GPUs cannot directly load the reference text encoder):

```bash
docker compose -f compose.yaml -f compose.shotstream.yaml run --rm shotstream \
  bash tools/inference/causal_fewsteps.sh
```

**Important:** The official 11.4 GB T5 text encoder is directly moved to the GPU in `utils/wan_wrapper.py`, so the reference code does **not** fit on an 8 GB RTX 4060 Ti without modifications. Do not confuse successful Docker build with successful inference.

## `decord 0.6.0 is not supported on this platform` build error

`decord==0.6.0` publishes a Linux wheel named `py3-none-manylinux2010_x86_64`
whose internal `WHEEL` metadata incorrectly claims `cp36-cp36m`. Newer
`pip check` reports it as unsupported under Python 3.10 even when the module
imports correctly. The companion `check_dependencies.py` confirms the
`decord` import works and runs `pip check`, allowing **only** that exact
known false-positive; any other package conflict fails the build.

Reference: https://github.com/dmlc/decord/issues/356

After replacing the files, rebuild using the existing cached layers:

```bash
docker compose -f compose.yaml -f compose.shotstream.yaml build
```

This checks package imports/dependency metadata only. PyTorch CUDA execution
requires a separate GPU test and the earlier Error 500 must already be fixed.
