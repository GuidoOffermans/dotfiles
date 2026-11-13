#!/bin/bash
# oh-my-posh: a devvm layer. devvm runs it once, with bash as the VM's user (who has sudo), in an image
# on top of base: devvm build oh-my-posh builds it, and a new VM gets it with --layers oh-my-posh. Editing it rebuilds that image,
# and the ones built on it, on next use.
# - Put PATH changes in ~/.profile.
# - Download with devvm-fetch URL SHA256 OUT: it fails when the checksum doesn't match.
# - On the allowlist tier, oh-my-posh.policy next to this file lists the hosts VMs with this layer reach.
set -euo pipefail

# The oh-my-posh prompt from the dotfiles, in place of oh-my-bash's theme.
# To update oh-my-posh: change the version and both checksums (from checksums.txt on the release).
omp_version=31.9.1
omp_sha256_amd64=574074a4e84797180e0bda0d133da5f01fbda89ecdb450134c7e566b9a389212
omp_sha256_arm64=a04e7aed0d233ac861161c0f3d4d70912b0747764fd5b10f6bd19c0b6510eb49

# devvm 0.1.0 gives its own layers $devvm_arch, but not ours, so work it out here.
case "$(uname -m)" in
  aarch64 | arm64) arch=arm64 sha=$omp_sha256_arm64 ;;
  x86_64 | amd64) arch=amd64 sha=$omp_sha256_amd64 ;;
  *) echo "oh-my-posh: no build for $(uname -m)" >&2; exit 1 ;;
esac
devvm-fetch "https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/v$omp_version/posh-linux-$arch" \
  "$sha" /tmp/oh-my-posh
sudo install -m 0755 /tmp/oh-my-posh /usr/local/bin/oh-my-posh
rm /tmp/oh-my-posh

# The theme: a copy of ohmyposh/.mytheme.omp.toml in the dotfiles repo. After changing that file,
# paste it again between the THEME_EOF lines; the image rebuilds the next time it's used.
sudo mkdir -p /usr/local/share/oh-my-posh
sudo tee /usr/local/share/oh-my-posh/theme.omp.toml >/dev/null <<'THEME_EOF'
console_title_template = '{{ .Shell }} in {{ .Folder }}'
version = 3
final_space = true

[secondary_prompt]
  template = '❯❯ '
  foreground = 'magenta'
  background = 'transparent'

[transient_prompt]
  template = '❯ '
  background = 'transparent'
  foreground_templates = ['{{if gt .Code 0}}red{{end}}', '{{if eq .Code 0}}magenta{{end}}']

[[blocks]]
  type = 'prompt'
  alignment = 'left'
  newline = true

  [[blocks.segments]]
    template = '{{ .Path }}'
    foreground = 'blue'
    background = 'transparent'
    type = 'path'
    style = 'plain'

    [blocks.segments.properties]
      cache_duration = 'none'
      style = 'full'
      # devvm VMs keep the Mac path for projects, outside the VM's own home, so show it as ~ there too
      mapped_locations = { '/Users/guidooffermans' = '~' }

  [[blocks.segments]]
  template = '{{ if .Env.IN_NIX_SHELL }} ❄️{{ end }}'
    foreground = 'cyan'
    background = 'transparent'
    type = 'path'
    style = 'plain'

    [blocks.segments.properties]
      cache_duration = 'none'
      
  [[blocks.segments]]
    template = ' {{ .HEAD }}{{ if or (.Working.Changed) (.Staging.Changed) }}*{{ end }} <cyan>{{ if gt .Behind 0 }}⇣{{ end }}{{ if gt .Ahead 0 }}⇡{{ end }}</>'
    background = 'transparent'
    type = 'git'
    style = 'plain'

    [blocks.segments.properties]
      branch_icon = ''
      cache_duration = 'none'
      commit_icon = '@'
      fetch_status = true

[[blocks]]
  type = 'rprompt'
  overflow = 'hidden'

  [[blocks.segments]]
    template = '{{ .FormattedMs }}'
    foreground = 'yellow'
    background = 'transparent'
    type = 'executiontime'
    style = 'plain'

    [blocks.segments.properties]
      cache_duration = 'none'
      threshold = 5000

[[blocks]]
  type = 'prompt'
  alignment = 'left'
  newline = true

  [[blocks.segments]]
    template = '❯'
    background = 'transparent'
    type = 'text'
    style = 'plain'
    foreground_templates = ['{{if gt .Code 0}}red{{end}}', '{{if eq .Code 0}}magenta{{end}}']

    [blocks.segments.properties]
      cache_duration = 'none'
THEME_EOF

# Turn off oh-my-bash's theme, and load oh-my-posh from ~/.bashrc.d. "00-" makes it load before
# devvm's own prompt hook, which then still puts "(devvm) " in front of the prompt.
sed -i 's/^OSH_THEME=.*/OSH_THEME=""/' ~/.bashrc
mkdir -p ~/.bashrc.d
cat > ~/.bashrc.d/00-oh-my-posh.sh <<'INIT_EOF'
eval "$(oh-my-posh init bash --config /usr/local/share/oh-my-posh/theme.omp.toml)"
INIT_EOF
