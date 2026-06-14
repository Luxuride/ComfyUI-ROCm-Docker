# ============================================================
# Stage 1: Clone ComfyUI repository
# ============================================================
FROM alpine:latest AS clone

RUN apk add --no-cache git

WORKDIR /opt/ComfyUI

ARG COMFYUI_VERSION
RUN git clone https://github.com/Comfy-Org/ComfyUI.git . && \
    git checkout ${COMFYUI_VERSION} && \
    rm -rf .git

# ============================================================
# Stage 2: Runtime image
# ============================================================
FROM rocm/pytorch:rocm7.2.4_ubuntu24.04_py3.12_pytorch_release_2.10.0 AS runtime

WORKDIR /opt/ComfyUI

COPY --from=clone /opt/ComfyUI .

RUN pip3 install --no-cache-dir -r requirements.txt

# Set environment variables
ENV PYTHONPATH=/opt/ComfyUI
ENV HF_HOME=/opt/ComfyUI/models/checkpoints
ENV HIP_VISIBLE_DEVICES=0
ENV HSA_OVERRIDE_GFX_VERSION=11.0.0 

# Expose ComfyUI port
EXPOSE 8188

# Set volume mount points for persistent storage (models and custom nodes)
VOLUME ["/opt/ComfyUI/models", "/opt/ComfyUI/custom_nodes"]

# Default entrypoint to run ComfyUI via main.py
ENTRYPOINT ["python3.12", "main.py"]
CMD ["--listen", "0.0.0.0"]