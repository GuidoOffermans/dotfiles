#!/bin/bash
# gh: a devvm layer. devvm runs it once, with bash as the VM's user (who has sudo), in an image
# on top of base: devvm build gh builds it, and a new VM gets it with --layers gh. Editing it rebuilds that image,
# and the ones built on it, on next use.
# - Put PATH changes in ~/.profile.
# - Download with devvm-fetch URL SHA256 OUT: it fails when the checksum doesn't match.
# - On the allowlist tier, gh.policy next to this file lists the hosts VMs with this layer reach.
set -euo pipefail

# The GitHub CLI. It authenticates with the GH_TOKEN placeholder that `devvm secret use github`
# gives the VM; devvm's proxy swaps in the real token, which never enters the VM.
# To update: change the version and both checksums (from gh_<version>_checksums.txt on the release).
gh_version=2.103.3
gh_sha256_amd64=4c806978ffce1cec70853302a56d70ac6da4f19bae7adca4e1a8ab00633dd91d
gh_sha256_arm64=ee32df2323c8847f5fac6cb6b4b69ca75828e9329a8f22f677021f7b3306ce63

# devvm 0.1.0 gives its own layers $devvm_arch, but not ours, so work it out here.
case "$(uname -m)" in
  aarch64 | arm64) arch=arm64 sha=$gh_sha256_arm64 ;;
  x86_64 | amd64) arch=amd64 sha=$gh_sha256_amd64 ;;
  *) echo "gh: no build for $(uname -m)" >&2; exit 1 ;;
esac

devvm-fetch "https://github.com/cli/cli/releases/download/v$gh_version/gh_${gh_version}_linux_$arch.tar.gz" \
  "$sha" /tmp/gh.tar.gz
tar -xzf /tmp/gh.tar.gz -C /tmp
sudo install -m 0755 "/tmp/gh_${gh_version}_linux_$arch/bin/gh" /usr/local/bin/gh
rm -rf /tmp/gh.tar.gz "/tmp/gh_${gh_version}_linux_$arch"

# SSH agent forwarding is off in devvm VMs, so send GitHub's SSH remotes over HTTPS,
# where the token works. This only affects git inside the VM; the repo's remote URL is unchanged.
git config --global url."https://github.com/".insteadOf "git@github.com:"
git config --global --add url."https://github.com/".insteadOf "ssh://git@github.com/"
