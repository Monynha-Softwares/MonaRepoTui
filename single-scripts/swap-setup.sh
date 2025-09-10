#!/bin/bash
# Script para criar e configurar swapfile no Linux
# Uso: sudo ./swap-setup.sh [tamanho_em_GB]

# Verifica se o usuário é root
if [ "$(id -u)" -ne 0 ]; then
  echo "❌ Por favor, execute como root (sudo)."
  exit 1
fi

# Tamanho do swap (GB)
SIZE=${1:-2}

# Caminho do arquivo swap
SWAPFILE="/swapfile"

echo "🔍 Verificando swap atual..."
swapon --show || true

if [ -f "$SWAPFILE" ]; then
  echo "⚠️ Arquivo $SWAPFILE já existe. Abortando para não sobrescrever."
  exit 1
fi

echo "📦 Criando swapfile de ${SIZE}G..."
fallocate -l ${SIZE}G $SWAPFILE || dd if=/dev/zero of=$SWAPFILE bs=1M count=$((SIZE*1024)) status=progress

echo "🔒 Ajustando permissões..."
chmod 600 $SWAPFILE

echo "🛠️ Formatando swap..."
mkswap $SWAPFILE

echo "🚀 Ativando swap..."
swapon $SWAPFILE

echo "📄 Adicionando ao /etc/fstab para ser permanente..."
echo "$SWAPFILE none swap sw 0 0" | tee -a /etc/fstab

echo "📊 Swap ativado:"
swapon --show
free -h

echo "✨ Swapfile criado com sucesso! Tamanho: ${SIZE}G"
echo "ℹ️ Para ajustar a agressividade do swap, edite /etc/sysctl.conf e adicione: vm.swappiness=10"
