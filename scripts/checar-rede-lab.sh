#!/usr/bin/env bash
set -euo pipefail

alvo="${1:-}"

if [[ -z "$alvo" ]]; then
  echo "Uso: $0 <IP_DO_ALVO>"
  exit 1
fi

if [[ ! "$alvo" =~ ^192\.168\.56\.[0-9]{1,3}$ ]]; then
  echo "Por segurança, este script aceita somente a rede host-only 192.168.56.0/24."
  exit 1
fi

echo "Verificando conectividade com $alvo..."
ping -c 2 "$alvo"

echo
echo "Conferindo somente as portas do exercício (FTP, HTTP e SMB)..."
nmap -Pn -sV -p 21,80,139,445 "$alvo"
