#!/usr/bin/env bash
set -euo pipefail

# Configuration
BASE_URL="https://raw.githubusercontent.com/yungYEEZY/cuda-13-wheels/main/cuda_13.0.2"
FILE="flash_attn-2.8.4-cp312-cp312-linux_x86_64.whl"
SHA_FILE="${FILE}.sha256"
OUT_DIR="/workspace/fa2_cu130"
PARTS=(
  "${FILE}.part.001"
  "${FILE}.part.002"
  "${FILE}.part.003"
  "${FILE}.part.004"
)

WORK_DIR=$(mktemp -d -t fa2_build_XXXXXXXXXX)

cleanup() {
  echo "Cleaning up temporary files..."
  rm -rf "$WORK_DIR"
}
trap cleanup EXIT

echo "Working in: $WORK_DIR"
cd "$WORK_DIR"

echo "Downloading checksum file..."
curl -sSLf "${BASE_URL}/${SHA_FILE}" -o "$SHA_FILE"

for part in "${PARTS[@]}"; do
  echo "Downloading $part..."
  curl -sSLf "${BASE_URL}/${part}" -o "$part"

  echo "Verifying $part..."
  awk -v f="$part" '$2 == f { print $0 }' "$SHA_FILE" | shasum -a 256 -c - >/dev/null || {
    echo "Error: $part verification failed."
    exit 1
  }
done

echo "Assembling $FILE..."
cat $(printf "%s\n" "${PARTS[@]}" | sort -V) > "$FILE"

echo "Performing final verification..."
if awk -v f="$FILE" '$2 == f { print $0 }' "$SHA_FILE" | shasum -a 256 -c - >/dev/null; then
  echo "Verification successful."
  
  mkdir -p "$OUT_DIR"
  mv "$FILE" "$OUT_DIR/"
  echo "Moved valid wheel to $OUT_DIR/$FILE"
else
  echo "Error: Final wheel reconstruction failed checksum."
  exit 1
fi

echo "Process complete."
