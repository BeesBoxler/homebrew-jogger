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
CASK_PATH="$(cd "$(dirname "$0")/.." && pwd)/Casks/jogger-macos.rb"

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

CURRENT_VERSION=""
CURRENT_BASE=""
CURRENT_REV="0"
CURRENT_SHA_ARM=""
CURRENT_SHA_INTEL=""

if [ -f "$CASK_PATH" ]; then
  CURRENT_VERSION="$(sed -n 's/^[[:space:]]*version "\(.*\)"$/\1/p' "$CASK_PATH" | head -n1)"
  CURRENT_BASE="${CURRENT_VERSION%%,*}"
  if [[ "$CURRENT_VERSION" == *","* ]]; then
    CURRENT_REV="${CURRENT_VERSION##*,}"
  fi
  CURRENT_SHA_ARM="$(sed -n 's/^[[:space:]]*sha256 arm: "\(.*\)", intel: ".*"$/\1/p' "$CASK_PATH" | head -n1)"
  CURRENT_SHA_INTEL="$(sed -n 's/^[[:space:]]*sha256 arm: ".*", intel: "\(.*\)"$/\1/p' "$CASK_PATH" | head -n1)"
fi

CASK_VERSION="$VERSION"
if [ "$CURRENT_BASE" = "$VERSION" ]; then
  if [ "$CURRENT_SHA_ARM" != "$SHA_ARM" ] || [ "$CURRENT_SHA_INTEL" != "$SHA_INTEL" ]; then
    NEXT_REV=$((CURRENT_REV + 1))
    CASK_VERSION="${VERSION},${NEXT_REV}"
  else
    CASK_VERSION="$CURRENT_VERSION"
  fi
fi

cat > "$CASK_PATH" <<RUBY
cask "jogger-macos" do
  version "${CASK_VERSION}"

  arch arm: "aarch64", intel: "x86_64"

  sha256 arm: "${SHA_ARM}", intel: "${SHA_INTEL}"

  url "https://github.com/${OWNER}/${REPO}/releases/download/v#{version.before_comma}/jogger-macos-#{arch}-apple-darwin.zip"
  name "Jogger"
  desc "Simple Jira time logger"
  homepage "https://github.com/${OWNER}/${REPO}"

  app "Jogger.app"

  postflight do
    plist_path = "#{Dir.home}/Library/LaunchAgents/com.jogger.macos.plist"
    plist_contents = <<~PLIST
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
          <key>Label</key>
          <string>com.jogger.macos</string>
          <key>ProgramArguments</key>
          <array>
              <string>/usr/bin/open</string>
              <string>#{appdir}/Jogger.app</string>
          </array>
          <key>RunAtLoad</key>
          <true/>
          <key>KeepAlive</key>
          <false/>
      </dict>
      </plist>
    PLIST

    system_command "/bin/mkdir",
      args: ["-p", "#{Dir.home}/Library/LaunchAgents"],
      sudo: false,
      must_succeed: false
    File.write(plist_path, plist_contents)

    system_command "/bin/launchctl",
      args: ["bootout", "gui/#{Process.uid}", plist_path],
      sudo: false,
      print_stderr: false,
      must_succeed: false
    system_command "/bin/launchctl",
      args: ["bootstrap", "gui/#{Process.uid}", plist_path],
      sudo: false,
      must_succeed: false

    system_command "/usr/bin/xattr",
      args: ["-dr", "com.apple.quarantine", "#{appdir}/Jogger.app"],
      sudo: false,
      must_succeed: false
  end
end
RUBY

echo "Updated Casks/jogger-macos.rb for v${VERSION} (cask version: ${CASK_VERSION})"
