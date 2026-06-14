# ComfyUI-ROCm-Docker

Docker image for [ComfyUI](https://github.com/Comfy-Org/ComfyUI) with AMD ROCm GPU acceleration, based on the official [rocm/pytorch](https://hub.docker.com/r/rocm/pytorch) image. Automatically built and published whenever a new ComfyUI release is detected.

## Usage

```bash
docker run --rm -p 8188:8188 \
  --device /dev/kfd --device /dev/dri \
  -v $(pwd)/models:/opt/ComfyUI/models \
  -v $(pwd)/input:/opt/ComfyUI/input \
  -v $(pwd)/output:/opt/ComfyUI/output \
  -v $(pwd)/custom_nodes:/opt/ComfyUI/custom_nodes \
  -v $(pwd)/user:/opt/ComfyUI/user \
  ghcr.io/luxuride/comfyui-rocm-docker:latest
```

```yaml
services:
  comfyui:
    image: ghcr.io/luxuride/comfyui-rocm-docker:latest
    container_name: comfyui-rocm
    devices:
      - /dev/kfd:/dev/kfd
      - /dev/dri:/dev/dri
    volumes:
      - ./models:/opt/ComfyUI/models
      - ./input:/opt/ComfyUI/input
      - ./output:/opt/ComfyUI/output
      - ./custom_nodes:/opt/ComfyUI/custom_nodes
      - ./user:/opt/ComfyUI/user
    ports:
      - "8188:8188"
    restart: unless-stopped
```

## Volumes

| Path | Purpose |
|---|---|
| `models/` | Checkpoint and model files |
| `custom_nodes/` | Custom node installations |
| `input/` | Input files |
| `output/` | Generated outputs |
| `user/` | User data and settings |

## Automated Builds

A daily GitHub Action checks for new ComfyUI releases and creates a corresponding tag, triggering an automatic image build.