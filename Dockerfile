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
ENV PYTHONUNBUFFERED=1
ENV HIP_VISIBLE_DEVICES=0
ENV HSA_OVERRIDE_GFX_VERSION=11.0.0 

# Expose ComfyUI port
EXPOSE 8188

# Copy repository defaults to a separate location so they survive bind mounts
RUN mkdir -p /opt/ComfyUI_defaults && \
    cp -r models /opt/ComfyUI_defaults/models && \
    cp -r input /opt/ComfyUI_defaults/input && \
    cp -r output /opt/ComfyUI_defaults/output

# Init script: copy default content into mount points if they are empty
COPY init_defaults.sh /opt/init_defaults.sh
RUN chmod +x /opt/init_defaults.sh

# Entrypoint wrapper: run init then exec into ComfyUI
COPY entrypoint.sh /opt/entrypoint.sh
RUN chmod +x /opt/entrypoint.sh

# Set volume mount points for persistent storage
VOLUME ["/opt/ComfyUI/models", "/opt/ComfyUI/custom_nodes", "/opt/ComfyUI/input", "/opt/ComfyUI/output", "/opt/ComfyUI/user"]

# Default entrypoint: init defaults then run ComfyUI
ENTRYPOINT ["/opt/entrypoint.sh"]
CMD ["--listen", "0.0.0.0"]
