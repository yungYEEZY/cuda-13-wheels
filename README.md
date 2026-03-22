# CUDA 1.30 wheels
 - SageAttention v2
 - SageAttention v3
 - flash-attention v2
 - dlib

## Build wheels 

```
vastai search offers 'verified=True rentable=True cpu_cores >=64 cuda_vers >= 13.0 gpu_ram <= 12 num_gpus=1' -b -o dph
export OFFER_ID=
vastai create instance $OFFER_ID --image vastai/pytorch:cuda-13.0.2-auto --onstart-cmd 'entrypoint.sh' --disk 50 --ssh --direct
export RUNNING_INSTANCE_ID=
SSH_URL=$(vastai ssh-url $RUNNING_INSTANCE_ID) export INSTANCE_IP=$(echo $SSH_URL | sed 's/ssh:\/\/root@\([^:]*\):.*/\1/') export INSTANCE_PORT=$(echo $SSH_URL | sed 's/ssh:\/\/root@[^:]*:\(.*\)/\1/')
ssh -p ${INSTANCE_PORT} root@${INSTANCE_IP}
git clone https://github.com/Dao-AILab/flash-attention
cd flash-attention
pip install ninja psutil packaging
pyton setup.py bdist_wheel
cd /workspace
git clone https://github.com/thu-ml/SageAttention
cd SageAttention
pyton setup.py bdist_wheel
git clean -fdx
cd sageattention3_blackwell
pyton setup.py bdist_wheel
mkdir -p /workspace/wheels
cd /workspace
git clone https://github.com/davisking/dlib
cd dlib
pyton setup.py bdist_wheel
mv /workspace/SageAttention/dist/*.whl /workspace/wheels
mv /workspace/SageAttention/sageattention3_blackwell/dist/*.whl /workspace/wheels
mv /workspace/flash-attention/dist/*.whl /workspace/wheels
mv /workspace/dlib/dist/*.whl /workspace/wheels
exit
scp -r -P ${INSTANCE_PORT} root@${INSTANCE_IP}:/workspace/wheels/ ./cuda_13.0.1
vastai destroy instance $RUNNING_INSTANCE_ID
```

## Split flash_attn-2.8.4-cp312-cp312-linux_x86_64.whl

```
cd cuda_13.0.1
file="flash_attn-2.8.4-cp312-cp312-linux_x86_64.whl"
chunk_size=$((90 * 1024 * 1024))
prefix="$file.part."
split -b $chunk_size -a 3 "$file" "$prefix"
i=1
for f in $(ls "$prefix"* | sort); do
  printf -v n "%03d" $i
  mv "$f" "${prefix}${n}"
  ((i++))
done
echo "Generating checksums..."
shasum -a 256 "$file" > "$file.sha256"
shasum -a 256 "$prefix"* >> "$file.sha256"
```

## Rebuild flash_attn-2.8.4-cp312-cp312-linux_x86_64.whl
```
curl -O https://raw.githubusercontent.com/yungYEEZY/cuda-13-wheels/refs/heads/main/cuda_13.0.1/fa2.sh
./fa2.sh
pip install flash_attn-2.8.4-cp312-cp312-linux_x86_64.whl

Processing ./flash_attn-2.8.4-cp312-cp312-linux_x86_64.whl
Requirement already satisfied: torch in /venv/main/lib/python3.12/site-packages (from flash-attn==2.8.4) (2.10.0+cu130)
Collecting einops (from flash-attn==2.8.4)
  Downloading einops-0.8.2-py3-none-any.whl.metadata (13 kB)
Requirement already satisfied: filelock in /venv/main/lib/python3.12/site-packages (from torch->flash-attn==2.8.4) (3.25.2)
Requirement already satisfied: typing-extensions>=4.10.0 in /venv/main/lib/python3.12/site-packages (from torch->flash-attn==2.8.4) (4.15.0)
Requirement already satisfied: setuptools in /venv/main/lib/python3.12/site-packages (from torch->flash-attn==2.8.4) (82.0.1)
Requirement already satisfied: sympy>=1.13.3 in /venv/main/lib/python3.12/site-packages (from torch->flash-attn==2.8.4) (1.14.0)
Requirement already satisfied: networkx>=2.5.1 in /venv/main/lib/python3.12/site-packages (from torch->flash-attn==2.8.4) (3.6.1)
Requirement already satisfied: jinja2 in /venv/main/lib/python3.12/site-packages (from torch->flash-attn==2.8.4) (3.1.6)
Requirement already satisfied: fsspec>=0.8.5 in /venv/main/lib/python3.12/site-packages (from torch->flash-attn==2.8.4) (2026.2.0)
Requirement already satisfied: cuda-bindings==13.0.3 in /venv/main/lib/python3.12/site-packages (from torch->flash-attn==2.8.4) (13.0.3)
Requirement already satisfied: nvidia-cuda-nvrtc==13.0.88 in /venv/main/lib/python3.12/site-packages (from torch->flash-attn==2.8.4) (13.0.88)
Requirement already satisfied: nvidia-cuda-runtime==13.0.96 in /venv/main/lib/python3.12/site-packages (from torch->flash-attn==2.8.4) (13.0.96)
Requirement already satisfied: nvidia-cuda-cupti==13.0.85 in /venv/main/lib/python3.12/site-packages (from torch->flash-attn==2.8.4) (13.0.85)
Requirement already satisfied: nvidia-cudnn-cu13==9.15.1.9 in /venv/main/lib/python3.12/site-packages (from torch->flash-attn==2.8.4) (9.15.1.9)
Requirement already satisfied: nvidia-cublas==13.1.0.3 in /venv/main/lib/python3.12/site-packages (from torch->flash-attn==2.8.4) (13.1.0.3)
Requirement already satisfied: nvidia-cufft==12.0.0.61 in /venv/main/lib/python3.12/site-packages (from torch->flash-attn==2.8.4) (12.0.0.61)
Requirement already satisfied: nvidia-curand==10.4.0.35 in /venv/main/lib/python3.12/site-packages (from torch->flash-attn==2.8.4) (10.4.0.35)
Requirement already satisfied: nvidia-cusolver==12.0.4.66 in /venv/main/lib/python3.12/site-packages (from torch->flash-attn==2.8.4) (12.0.4.66)
Requirement already satisfied: nvidia-cusparse==12.6.3.3 in /venv/main/lib/python3.12/site-packages (from torch->flash-attn==2.8.4) (12.6.3.3)
Requirement already satisfied: nvidia-cusparselt-cu13==0.8.0 in /venv/main/lib/python3.12/site-packages (from torch->flash-attn==2.8.4) (0.8.0)
Requirement already satisfied: nvidia-nccl-cu13==2.28.9 in /venv/main/lib/python3.12/site-packages (from torch->flash-attn==2.8.4) (2.28.9)
Requirement already satisfied: nvidia-nvshmem-cu13==3.4.5 in /venv/main/lib/python3.12/site-packages (from torch->flash-attn==2.8.4) (3.4.5)
Requirement already satisfied: nvidia-nvtx==13.0.85 in /venv/main/lib/python3.12/site-packages (from torch->flash-attn==2.8.4) (13.0.85)
Requirement already satisfied: nvidia-nvjitlink==13.0.88 in /venv/main/lib/python3.12/site-packages (from torch->flash-attn==2.8.4) (13.0.88)
Requirement already satisfied: nvidia-cufile==1.15.1.6 in /venv/main/lib/python3.12/site-packages (from torch->flash-attn==2.8.4) (1.15.1.6)
Requirement already satisfied: triton==3.6.0 in /venv/main/lib/python3.12/site-packages (from torch->flash-attn==2.8.4) (3.6.0)
Requirement already satisfied: cuda-pathfinder~=1.1 in /venv/main/lib/python3.12/site-packages (from cuda-bindings==13.0.3->torch->flash-attn==2.8.4) (1.4.3)
Requirement already satisfied: mpmath<1.4,>=1.1.0 in /venv/main/lib/python3.12/site-packages (from sympy>=1.13.3->torch->flash-attn==2.8.4) (1.3.0)
Requirement already satisfied: MarkupSafe>=2.0 in /venv/main/lib/python3.12/site-packages (from jinja2->torch->flash-attn==2.8.4) (3.0.3)
Downloading einops-0.8.2-py3-none-any.whl (65 kB)
Installing collected packages: einops, flash-attn
Successfully installed einops-0.8.2 flash-attn-2.8.4
```
