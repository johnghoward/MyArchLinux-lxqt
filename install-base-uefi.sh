#!/bin/bash
# =============================================================================
# my-archlinux-lxqt Install Script
# Base system + AI/ML/Data Science tools
# =============================================================================

# --- Locale & Time ---
ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
hwclock --systohc
sed -i '177s/.//' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "KEYMAP=us" >> /etc/vconsole.conf

# --- Hostname ---
echo "my-archlinux-lxqt" >> /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 my-archlinux-lxqt.localdomain my-archlinux-lxqt" >> /etc/hosts

# --- Root password ---
echo root:archlinux | chpasswd

# =============================================================================
# BASE PACKAGES
# =============================================================================
pacman -S --noconfirm \
    grub efibootmgr \
    networkmanager network-manager-applet dialog wpa_supplicant \
    mtools dosfstools reflector \
    base-devel linux-headers go \
    avahi xdg-user-dirs xdg-utils \
    gvfs gvfs-smb nfs-utils inetutils dnsutils \
    bluez bluez-utils \
    cups hplip \
    alsa-utils alsa-plugins pipewire pipewire-alsa pipewire-pulse pipewire-bluetooth wireplumber \
    bash-completion fish \
    openssh rsync \
    acpi acpi_call tlp \
    virt-manager qemu-full edk2-ovmf bridge-utils dnsmasq vde2 openbsd-netcat \
    iptables-nft ipset firewalld \
    flatpak \
    sof-firmware nss-mdns acpid \
    os-prober ntfs-3g \
    packagekit cockpit \
    git curl wget unzip zip p7zip \
    htop btop neofetch \
    vim nano \
    btrfs-progs snapper \
    paru

# =============================================================================
# PYTHON ECOSYSTEM
# =============================================================================
pacman -S --noconfirm \
    python python-setuptools python-pip python-wheel \
    python-virtualenv python-pipx \
    python-numpy python-scipy python-pandas \
    python-matplotlib python-seaborn python-plotly \
    python-scikit-learn \
    python-requests python-httpx \
    python-pydantic \
    python-tqdm python-rich \
    python-click

# =============================================================================
# R + DATA SCIENCE
# =============================================================================
pacman -S --noconfirm \
    r \
    perl perl-cgi \
    gcc-fortran                 # Required for many R packages

# Install key R packages (runs as root during install; user can add more)
Rscript --no-save <<'REOF'
install.packages(c(
    "tidyverse",        # ggplot2, dplyr, tidyr, readr, purrr, etc.
    "data.table",       # Fast data manipulation
    "caret",            # Classification and regression training
    "randomForest",
    "xgboost",
    "glmnet",
    "ggplot2",
    "plotly",           # Interactive plots
    "shiny",            # R web apps
    "rmarkdown",        # R Markdown
    "knitr",
    "devtools",
    "remotes",
    "pak",              # Modern package installer
    "jsonlite",
    "httr2",            # HTTP requests
    "reticulate"        # R-Python bridge
), repos = "https://cran.rstudio.com/", dependencies = TRUE)
REOF

# =============================================================================
# JUPYTER ECOSYSTEM
# =============================================================================
pip install --break-system-packages \
    jupyterlab \
    notebook \
    jupyterlab-git \
    jupyterlab-lsp \
    jupyter-ai \                 # AI assistant inside JupyterLab
    nbconvert \
    nbformat \
    ipywidgets \
    ipykernel \
    ipython \
    voila                        # Turn notebooks into web apps

# Install R kernel for Jupyter
Rscript --no-save -e "install.packages('IRkernel', repos='https://cran.rstudio.com/')"
Rscript --no-save -e "IRkernel::installspec(user = FALSE)"  # system-wide

# =============================================================================
# AI / ML FRAMEWORKS
# =============================================================================
pip install --break-system-packages \
    torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu \
    tensorflow-cpu \
    scikit-learn \
    xgboost \
    lightgbm \
    catboost \
    optuna                       # Hyperparameter optimization

# =============================================================================
# HUGGING FACE ECOSYSTEM
# =============================================================================
pip install --break-system-packages \
    transformers \               # Core HF library
    datasets \                   # HF datasets
    huggingface_hub \            # Model downloads, repo management
    accelerate \                 # Distributed/mixed precision training
    peft \                       # Parameter-efficient fine-tuning (LoRA, etc.)
    trl \                        # RLHF / SFT training
    diffusers \                  # Stable Diffusion & image generation
    tokenizers \                 # Fast tokenizers
    evaluate \                   # Model evaluation metrics
    bitsandbytes \               # 4-bit / 8-bit quantization (QLoRA)
    sentence-transformers        # Embeddings

# =============================================================================
# OLLAMA (local LLM inference)
# =============================================================================
# Install Ollama via official installer
curl -fsSL https://ollama.com/install.sh | sh

# Create systemd service override for Ollama (allow API on all interfaces)
mkdir -p /etc/systemd/system/ollama.service.d
cat > /etc/systemd/system/ollama.service.d/override.conf <<'EOF'
[Service]
Environment="OLLAMA_HOST=0.0.0.0:11434"
Environment="OLLAMA_ORIGINS=*"
EOF

# Enable Ollama service
systemctl enable ollama

# =============================================================================
# LLM TOOLING & APIS
# =============================================================================
pip install --break-system-packages \
    ollama \                     # Python client for Ollama
    openai \                     # OpenAI-compatible API client
    anthropic \                  # Anthropic Claude API
    langchain langchain-community langchain-ollama \
    llama-index llama-index-llms-ollama \
    litellm \                    # Universal LLM proxy
    instructor \                 # Structured outputs from LLMs
    outlines \                   # Guided generation / constrained decoding
    guidance                     # Microsoft Guidance for structured LLM outputs

# =============================================================================
# VECTOR DATABASES & RAG
# =============================================================================
pip install --break-system-packages \
    chromadb \                   # Local vector database
    faiss-cpu \                  # Facebook AI Similarity Search
    qdrant-client \              # Qdrant vector DB client
    pymilvus                     # Milvus client

# =============================================================================
# MLOps & EXPERIMENT TRACKING
# =============================================================================
pip install --break-system-packages \
    mlflow \                     # Experiment tracking & model registry
    wandb \                      # Weights & Biases
    dvc \                        # Data version control
    bentoml                      # Model serving

# =============================================================================
# DATA TOOLS
# =============================================================================
pip install --break-system-packages \
    polars \                     # Fast DataFrame library (Rust-backed)
    duckdb \                     # In-process analytical SQL
    pyarrow \                    # Apache Arrow / Parquet
    sqlalchemy \
    psycopg2-binary \
    pymongo \
    redis \
    streamlit \                  # Quick ML/data web apps
    gradio                       # LLM/ML demos & UIs

# =============================================================================
# GRUB BOOTLOADER
# =============================================================================
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# =============================================================================
# SYSTEMD SERVICES
# =============================================================================
systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable cups.service
systemctl enable sshd
systemctl enable avahi-daemon
systemctl enable tlp
systemctl enable reflector.timer
systemctl enable fstrim.timer
systemctl enable libvirtd
systemctl enable firewalld
systemctl enable acpid
systemctl enable --now cockpit
systemctl enable ollama

# =============================================================================
# USER SETUP
# =============================================================================
useradd -m -s /usr/bin/fish archlinux
echo archlinux:password | chpasswd
usermod -aG libvirt,wheel,audio,video,optical,storage,docker archlinux

echo "archlinux ALL=(ALL) ALL" >> /etc/sudoers.d/archlinux
chmod 440 /etc/sudoers.d/archlinux

# =============================================================================
# OLLAMA HELPER FUNCTIONS  (added to fish config)
# =============================================================================
mkdir -p /home/archlinux/.config/fish/functions

cat > /home/archlinux/.config/fish/functions/ollama_pull_models.fish <<'FISH'
function ollama_pull_models --description "Pull a curated set of useful Ollama models"
    set models \
        "llama3.2:3b" \
        "mistral:7b" \
        "codellama:7b" \
        "nomic-embed-text" \
        "llava:7b"
    for model in $models
        echo "Pulling $model..."
        ollama pull $model
    end
    echo "Done. Run 'ollama list' to see installed models."
end
FISH

cat > /home/archlinux/.config/fish/functions/ollama_chat.fish <<'FISH'
function ollama_chat --description "Quick chat with a local model (default: llama3.2:3b)"
    set model (test -n "$argv[1]"; and echo $argv[1]; or echo "llama3.2:3b")
    ollama run $model
end
FISH

cat > /home/archlinux/.config/fish/functions/jlab.fish <<'FISH'
function jlab --description "Launch JupyterLab in current directory"
    jupyter lab --no-browser --ip=0.0.0.0 &
    echo "JupyterLab running at http://localhost:8888"
end
FISH

cat > /home/archlinux/.config/fish/functions/hf_download.fish <<'FISH'
function hf_download --description "Download a model from Hugging Face Hub"
    # Usage: hf_download org/model-name [output-dir]
    if test (count $argv) -lt 1
        echo "Usage: hf_download <org/model-name> [output-dir]"
        return 1
    end
    set model_id $argv[1]
    set outdir (test -n "$argv[2]"; and echo $argv[2]; or echo "./models/$model_id")
    python3 -c "
from huggingface_hub import snapshot_download
snapshot_download(repo_id='$model_id', local_dir='$outdir')
print('Downloaded to $outdir')
"
end
FISH

cat > /home/archlinux/.config/fish/functions/mlflow_ui.fish <<'FISH'
function mlflow_ui --description "Start MLflow tracking UI"
    mlflow ui --host 0.0.0.0 --port 5000 &
    echo "MLflow UI at http://localhost:5000"
end
FISH

# Fix ownership
chown -R archlinux:archlinux /home/archlinux/.config

# =============================================================================
# JUPYTER CONFIG (allow remote access)
# =============================================================================
mkdir -p /home/archlinux/.jupyter
cat > /home/archlinux/.jupyter/jupyter_lab_config.py <<'PY'
c.ServerApp.ip = '0.0.0.0'
c.ServerApp.open_browser = False
c.ServerApp.port = 8888
c.ServerApp.allow_remote_access = True
PY
chown -R archlinux:archlinux /home/archlinux/.jupyter

# =============================================================================
# DONE
# =============================================================================
printf "\e[1;36m\n"
printf "╔══════════════════════════════════════════════╗\n"
printf "║         my-archlinux-lxqt Install Complete!           ║\n"
printf "╠══════════════════════════════════════════════╣\n"
printf "║  Type: exit → umount -a → reboot            ║\n"
printf "║  Then run: ./my-archlinux-lxqt-desktop.sh            ║\n"
printf "╠══════════════════════════════════════════════╣\n"
printf "║  AI/ML Tools installed:                     ║\n"
printf "║  • Ollama   (local LLMs)     port 11434     ║\n"
printf "║  • JupyterLab                port 8888      ║\n"
printf "║  • MLflow UI                 port 5000      ║\n"
printf "║  • Gradio/Streamlit apps     port 7860      ║\n"
printf "║                                              ║\n"
printf "║  Fish functions: ollama_chat, jlab,         ║\n"
printf "║    hf_download, ollama_pull_models,         ║\n"
printf "║    mlflow_ui                                ║\n"
printf "╚══════════════════════════════════════════════╝\n"
printf "\e[0m"
