#!/bin/bash
# lazygit: a devvm layer. devvm runs it once, with bash as the VM's user (who has sudo), in an image
# on top of base: devvm build lazygit builds it, and a new VM gets it with --layers lazygit. Editing it rebuilds that image,
# and the ones built on it, on next use.
# - Put PATH changes in ~/.profile.
# - Download with devvm-fetch URL SHA256 OUT: it fails when the checksum doesn't match.
# - On the allowlist tier, lazygit.policy next to this file lists the hosts VMs with this layer reach.
set -euo pipefail

# lazygit, the git TUI (lg on the Mac). It needs no config: the Mac's config.yml is empty.
# To update: change the version and both checksums (from checksums.txt on the release).
lazygit_version=0.66.3
lazygit_sha256_x86_64=0a23f429a95f0d09db298b3c291536d818de066aa5a85c255806f0490ff6656b
lazygit_sha256_arm64=ac0b48237f3d0283813e7154ec063237e519532feb0470c0881a1793ee78fd42

# devvm 0.1.0 gives its own layers $devvm_arch, but not ours, so work it out here.
case "$(uname -m)" in
  aarch64 | arm64) arch=arm64 sha=$lazygit_sha256_arm64 ;;
  x86_64 | amd64) arch=x86_64 sha=$lazygit_sha256_x86_64 ;;
  *) echo "lazygit: no build for $(uname -m)" >&2; exit 1 ;;
esac

devvm-fetch "https://github.com/jesseduffield/lazygit/releases/download/v$lazygit_version/lazygit_${lazygit_version}_linux_$arch.tar.gz" \
  "$sha" /tmp/lazygit.tar.gz
mkdir -p /tmp/lazygit
tar -xzf /tmp/lazygit.tar.gz -C /tmp/lazygit lazygit
sudo install -m 0755 /tmp/lazygit/lazygit /usr/local/bin/lazygit
rm -rf /tmp/lazygit.tar.gz /tmp/lazygit

# The same short name as on the Mac.
mkdir -p ~/.bashrc.d
echo "alias lg=lazygit" > ~/.bashrc.d/lazygit.sh
