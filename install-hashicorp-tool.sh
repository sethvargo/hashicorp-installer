#!/usr/bin/env sh
set -e

#
# Installs the given HashiCorp tool, verifying checksums and GPG signatures. Exits
# non-zero on failure.
#
# Usage:
#   install_hashicorp_tool.sh terraform 0.11.5
#
# Requirements:
#   - gpg, with hashicorp key trusted
#   - curl
#   - sha256sum


NAME="$1"
if [ -z "$NAME" ]; then
  echo "Missing NAME"
  exit 1
fi

VERSION="$2"
if [ -z "$VERSION" ]; then
  echo "Missing VERSION"
  exit
fi

OS="$3"
if [ -z "$OS" ]; then
  OS="linux"
fi

ARCH="$4"
if [ -z "$ARCH" ]; then
  ARCH="amd64"
fi

DOWNLOAD_ROOT="https://releases.hashicorp.com/${NAME}/${VERSION}/${NAME}_${VERSION}"
DOWNLOAD_ZIP="${DOWNLOAD_ROOT}_${OS}_${ARCH}.zip"
DOWNLOAD_SHA="${DOWNLOAD_ROOT}_SHA256SUMS"
DOWNLOAD_SIG="${DOWNLOAD_ROOT}_SHA256SUMS.sig"

echo "==> Installing ${NAME} v${VERSION}"

echo "--> Downloading SHASUM and SHASUM signatures"
curl -sfSO "${DOWNLOAD_SHA}"
curl -sfSO "${DOWNLOAD_SIG}"

echo "--> Verifying signatures file"
gpg --verify "${NAME}_${VERSION}_SHA256SUMS.sig" "${NAME}_${VERSION}_SHA256SUMS"

echo "--> Downloading ${NAME} v${VERSION} (${OS}/${ARCH})"
curl -sfSO "${DOWNLOAD_ZIP}"

echo "--> Validating SHA256SUM"
grep "${NAME}_${VERSION}_${OS}_${ARCH}.zip" "${NAME}_${VERSION}_SHA256SUMS" > "SHA256SUMS"
sha256sum -c "SHA256SUMS"

echo "--> Unpacking and installing"
mkdir -p "/software"
unzip "${NAME}_${VERSION}_${OS}_${ARCH}.zip"
mv "${NAME}" "/software/${NAME}"
chmod +x "/software/${NAME}"

echo "--> Removing temporary files"
rm "${NAME}_${VERSION}_${OS}_${ARCH}.zip"
rm "${NAME}_${VERSION}_SHA256SUMS"
rm "${NAME}_${VERSION}_SHA256SUMS.sig"

echo "--> Done!"
