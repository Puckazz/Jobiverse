#!/bin/bash
set -e

# ─────────────────────────────────────────────
# GitHub Secrets Importer Script for Jobiverse
# Author: nhatt
# ─────────────────────────────────────────────

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Insert GitHub Token
echo -e "${YELLOW}🔐 Nhập GitHub Token của bạn (sẽ không hiển thị):${NC}"
read -s TOKEN

if [[ -z "$TOKEN" ]]; then
  echo -e "${RED}❌ Token rỗng. Thoát.${NC}"
  exit 1
fi

# Temporary directory for cloning
TEMP_DIR="temp_secrets_$$"
REPO_URL="https://$TOKEN@github.com/nhattVim/.env"

echo -e "${YELLOW}🚀 Đang clone repository chứa secrets (tắt credential helper)...${NC}"
if git -c credential.helper= clone "$REPO_URL" "$TEMP_DIR" >/dev/null 2>&1; then
  echo -e "${GREEN}✅ Clone thành công!${NC}"
else
  echo -e "${RED}❌ Lỗi khi clone repo. Kiểm tra lại token hoặc quyền truy cập.${NC}"
  exit 1
fi

# Mapping: [src]=dst
declare -A FILES_TO_COPY=(
  ["Jobiverse/backend/.env"]="backend/.env"
  ["Jobiverse/backend.NET/appsettings.json"]="backend.NET/appsettings.json"
  ["Jobiverse/frontend/.env"]="frontend/.env"
)

echo -e "${YELLOW}📂 Đang sao chép các file cấu hình...${NC}"
for SRC in "${!FILES_TO_COPY[@]}"; do
  DST=${FILES_TO_COPY[$SRC]}
  FULL_SRC="$TEMP_DIR/$SRC"
  if [ -f "$FULL_SRC" ]; then
    mkdir -p "$(dirname "$DST")"
    cp "$FULL_SRC" "$DST"
    echo -e "${GREEN}✅ Đã copy $DST${NC}"
  else
    echo -e "${RED}⚠️ Không tìm thấy $SRC trong repo.${NC}"
  fi
done

# Cleanup
rm -rf "$TEMP_DIR"
echo -e "${YELLOW}🧹 Đã xoá thư mục tạm.${NC}"
echo -e "${GREEN}🎉 Hoàn tất import secrets!${NC}"
