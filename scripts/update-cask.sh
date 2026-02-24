#!/usr/bin/env bash
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <version>" >&2
  exit 1
fi

VERSION="$1"
OWNER="BeesBoxler"
REPO="jogger"
APP="jogger-macos"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

asset_url() {
  local arch="$1"
  echo "https://github.com/${OWNER}/${REPO}/releases/download/v${VERSION}/${APP}-${arch}-apple-darwin.zip"
}

fetch_sha() {
  local arch="$1"
  local file="$TMP_DIR/${APP}-${arch}.zip"
  curl -fL "$(asset_url "$arch")" -o "$file" >/dev/null
  shasum -a 256 "$file" | awk '{print $1}'
}

SHA_ARM="$(fetch_sha aarch64)"
SHA_INTEL="$(fetch_sha x86_64)"

cat > "$(cd "$(dirname "$0")/.." && pwd)/Casks/jogger-macos.rb" <<RUBY
cask "jogger-macos" do
  version "${VERSION}"

  arch arm: "aarch64", intel: "x86_64"

  sha256 arm: "${SHA_ARM}"
  sha256 intel: "${SHA_INTEL}"

  url "https://github.com/${OWNER}/${REPO}/releases/download/v#{version}/jogger-macos-#{arch}-apple-darwin.zip"
  name "Jogger"
  desc "Simple Jira time logger"
  homepage "https://github.com/${OWNER}/${REPO}"

  app "Jogger.app"
end
RUBY

echo "Updated Casks/jogger-macos.rb for v${VERSION}"
