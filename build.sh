#!/bin/sh
# 构建期从 GitHub 拉取固定提交的静态站点，放进 content/web。
# 仓库本身不保存上游源码；GitHub Actions 每次构建都重新获取。
set -eu

cd "$(dirname "$0")"
. ./UPSTREAM.conf

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

SRC_TARBALL="${UPSTREAM_TARBALL:-https://github.com/${REPO}/archive/${COMMIT}.tar.gz}"
if [ -f "${SRC_TARBALL}" ]; then
  echo "using local tarball ${SRC_TARBALL}"
  cp "${SRC_TARBALL}" "${TMP}/upstream.tar.gz"
else
  echo "fetching ${SRC_TARBALL}"
  curl -fsSL --retry 3 --retry-delay 2 -o "${TMP}/upstream.tar.gz" "${SRC_TARBALL}"
fi

mkdir -p "${TMP}/x"
tar -xzf "${TMP}/upstream.tar.gz" -C "${TMP}/x"
SRC="$(find "${TMP}/x" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
if [ -z "${SRC}" ] || [ ! -f "${SRC}/index.html" ]; then
  echo "upstream archive does not contain index.html" >&2
  exit 1
fi

rm -rf content/web
mkdir -p content/web
# 只带运行需要的静态资源（跳过 .git 与仓库元数据文件）
cp -R "${SRC}"/index.html "${SRC}"/game.min.js "${SRC}"/three.min.js "${SRC}"/assets content/web/
cp -f "${SRC}"/THREE-LICENSE.txt content/web/ 2>/dev/null || true

# 构建产物自检：入口与主脚本必须在，且不引用外部域名
test -f content/web/index.html
test -f content/web/game.min.js
if grep -qE 'https?://[^"'"'"' ]+' content/web/index.html; then
  echo "index.html unexpectedly references external URLs" >&2
  exit 1
fi
echo "content ready: $(du -sh content/web | cut -f1)"
