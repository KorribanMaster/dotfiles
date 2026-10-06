#!/bin/bash

set -euo pipefail

URL="https://github.com/KorribanMaster/dotfiles.git"
INSTALL_DIR="$HOME/dotfiles"
DRY_RUN="false"
SKIP_SHELL="${SKIP_SHELL:-false}"
SKIP_DEPENDENCIES="false"
OS="$(uname -s)"
DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
BIN_DIR="$HOME/.local/bin"
FNM_DIR="${FNM_DIR:-$DATA_HOME/fnm}"
TEMP_DIR=""

cleanup() {
  if [ -n "$TEMP_DIR" ]; then
    rm -rf -- "$TEMP_DIR"
  fi
}
trap cleanup EXIT

# When run from a checkout, install that checkout rather than cloning over it.
if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
  SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
  if [ -e "$SCRIPT_DIR/../.git" ] && [ -d "$SCRIPT_DIR/../.config" ]; then
    INSTALL_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd -P)"
  fi
fi

usage() {
  cat <<'EOF'
Usage: setup.sh [options]

  -d, --install-dir DIR  Use or clone the dotfiles checkout at DIR
  --dry-run             Preview installs and symlinks without making changes
  --skip-dependencies   Only link dotfiles; do not install tools
  --skip-shell          Skip shell reload instructions
  -h, --help            Show this help

Existing files are never adopted or overwritten. Back up conflicting files
before running the installer again. System packages may require sudo; run this
script as your normal user, not with sudo. macOS requires Homebrew.
EOF
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
    -d | --install-dir)
      if [ "$#" -lt 2 ] || [ -z "$2" ] || [[ "$2" == -* ]]; then
        echo "Error: $1 requires a directory." >&2
        exit 1
      fi
      INSTALL_DIR="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN="true"
      shift
      ;;
    --skip-shell)
      SKIP_SHELL="true"
      shift
      ;;
    --skip-dependencies)
      SKIP_DEPENDENCIES="true"
      shift
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "Unrecognized argument: $1" >&2
      usage >&2
      exit 1
      ;;
    esac
  done
}

check_os() {
  case "$OS" in
  Linux | Darwin) ;;
  *)
    echo "OS $OS is not supported." >&2
    exit 1
    ;;
  esac
}

download_dotfiles() {
  if [ -e "$INSTALL_DIR/.git" ]; then
    echo "Using existing checkout at $INSTALL_DIR."
  else
    if [ "$DRY_RUN" = "true" ]; then
      echo "Would clone $URL into $INSTALL_DIR."
      return
    fi
    echo "Cloning $URL into $INSTALL_DIR..."
    mkdir -p -- "$(dirname -- "$INSTALL_DIR")"
    git clone "$URL" "$INSTALL_DIR"
  fi

  if [ ! -f "$INSTALL_DIR/.bashrc" ] || [ ! -d "$INSTALL_DIR/.config" ]; then
    echo "Error: $INSTALL_DIR is not a dotfiles checkout." >&2
    exit 1
  fi
  INSTALL_DIR="$(cd -- "$INSTALL_DIR" && pwd -P)"
  if [ "$INSTALL_DIR" = "$(cd -- "$HOME" && pwd -P)" ]; then
    echo "Error: the checkout must not be your home directory." >&2
    exit 1
  fi
}

has_command() {
  command -v "$1" >/dev/null 2>&1
}

install_system_dependencies() {
  local manager tool package index
  local packages=()
  local tools=(git stow curl unzip tar gzip zsh tmux vim ssh rg fd cc make python3)
  local package_names=()

  if [ "$OS" = "Darwin" ]; then
    manager="brew"
    package_names=(git stow curl unzip gnu-tar gzip zsh tmux vim openssh ripgrep fd gcc make python)
  elif has_command apt-get; then
    manager="apt-get"
    package_names=(git stow curl unzip tar gzip zsh tmux vim openssh-client ripgrep fd-find build-essential build-essential python3)
  elif has_command dnf; then
    manager="dnf"
    package_names=(git stow curl unzip tar gzip zsh tmux vim-enhanced openssh-clients ripgrep fd-find gcc make python3)
  elif has_command pacman; then
    manager="pacman"
    package_names=(git stow curl unzip tar gzip zsh tmux vim openssh ripgrep fd base-devel base-devel python)
  else
    echo "Error: install dependencies manually; supported package managers are apt-get, dnf, pacman, and Homebrew." >&2
    echo "Then rerun with --skip-dependencies." >&2
    exit 1
  fi

  for index in "${!tools[@]}"; do
    tool="${tools[$index]}"
    if has_command "$tool" || { [ "$tool" = "fd" ] && has_command fdfind; }; then
      continue
    fi
    package="${package_names[$index]}"
    if [[ " ${packages[*]:-} " != *" $package "* ]]; then
      packages+=("$package")
    fi
  done

  # The default expansion also works with nounset on macOS's Bash 3.2.
  if [ -n "${packages[*]:-}" ]; then
    if [ "$DRY_RUN" = "true" ]; then
      echo "Would install system packages with $manager: ${packages[*]}"
      return
    fi
    if ! has_command "$manager"; then
      echo "Error: install Homebrew first: https://brew.sh" >&2
      exit 1
    fi
    if [ "$manager" != "brew" ] && [ "$EUID" -ne 0 ]; then
      if ! has_command sudo; then
        echo "Error: sudo is required to install system packages." >&2
        exit 1
      fi
    fi
    case "$manager" in
    apt-get)
      run_as_root apt-get update
      run_as_root apt-get install -y "${packages[@]}"
      ;;
    dnf) run_as_root dnf install -y "${packages[@]}" ;;
    pacman) run_as_root pacman -S --needed --noconfirm "${packages[@]}" ;;
    brew) brew install "${packages[@]}" ;;
    esac
  fi
}

run_as_root() {
  if [ "$EUID" -eq 0 ]; then
    "$@"
  else
    sudo "$@"
  fi
}

prepare_temp_dir() {
  if [ -z "$TEMP_DIR" ]; then
    local temp_root="${TMPDIR:-${XDG_CACHE_HOME:-$HOME/.cache}}"
    mkdir -p -- "$temp_root"
    TEMP_DIR="$(mktemp -d "$temp_root/dotfiles-setup.XXXXXX")"
  fi
}

run_installer() {
  local url="$1"
  local shell="$2"
  shift 2
  prepare_temp_dir
  # Download fully before executing, and propagate download failures.
  curl --proto '=https' --tlsv1.2 -fsSL "$url" -o "$TEMP_DIR/installer.sh"
  "$shell" "$TEMP_DIR/installer.sh" "$@"
  hash -r
}

link_binary() {
  local source="$1"
  local destination="$BIN_DIR/$2"
  if [ -e "$destination" ] || [ -L "$destination" ]; then
    if [ -L "$destination" ] && [ "$(readlink "$destination")" = "$source" ]; then
      return
    fi
    echo "Error: refusing to overwrite $destination. Move it aside first." >&2
    exit 1
  fi
  mkdir -p -- "$BIN_DIR"
  ln -s -- "$source" "$destination"
  hash -r
}

clone_tool() {
  local url="$1"
  local destination="$2"
  if [ ! -e "$destination" ]; then
    mkdir -p -- "$(dirname -- "$destination")"
    git clone --depth 1 "$url" "$destination"
  elif [ ! -e "$destination/.git" ]; then
    echo "Error: $destination already exists and is not a Git checkout." >&2
    exit 1
  fi
}

has_modern_nvim() {
  local version
  has_command nvim || return 1
  version="$(nvim --version)" || return 1
  [[ "$version" =~ NVIM\ v([0-9]+)\.([0-9]+) ]] || return 1
  [ "${BASH_REMATCH[1]}" -gt 0 ] || [ "${BASH_REMATCH[2]}" -ge 11 ]
}

install_neovim() {
  local platform architecture archive destination
  if has_modern_nvim; then
    return
  fi
  if [ "$DRY_RUN" = "true" ]; then
    echo "Would install current stable Neovim (configuration requires >= 0.11)."
    return
  fi
  case "$(uname -m)" in
  x86_64 | amd64) architecture="x86_64" ;;
  aarch64 | arm64) architecture="arm64" ;;
  *)
    echo "Error: install Neovim >= 0.11 manually on architecture $(uname -m)." >&2
    exit 1
    ;;
  esac
  case "$OS" in
  Linux) platform="linux" ;;
  Darwin) platform="macos" ;;
  esac
  archive="nvim-$platform-$architecture"
  prepare_temp_dir
  curl --proto '=https' --tlsv1.2 -fsSL \
    "https://github.com/neovim/neovim/releases/download/stable/$archive.tar.gz" \
    -o "$TEMP_DIR/nvim.tar.gz"
  tar -xzf "$TEMP_DIR/nvim.tar.gz" -C "$TEMP_DIR"
  destination="$HOME/.local/opt/$archive"
  if [ -e "$destination" ]; then
    echo "Error: $destination already exists. Move it aside before reinstalling Neovim." >&2
    exit 1
  fi
  mkdir -p -- "$HOME/.local/opt"
  mv -- "$TEMP_DIR/$archive" "$destination"
  link_binary "$destination/bin/nvim" nvim
  has_modern_nvim || { echo "Error: installed Neovim could not run." >&2; exit 1; }
}

install_user_dependencies() {
  local fzf_dir="$DATA_HOME/fzf"
  local zinit_dir="$DATA_HOME/zinit/zinit.git"

  if ! has_command fd && has_command fdfind; then
    if [ "$DRY_RUN" = "true" ]; then
      echo "Would link fdfind as $BIN_DIR/fd."
    else
      link_binary "$(command -v fdfind)" fd
    fi
  fi

  if ! { has_command rustc && rustc --version >/dev/null 2>&1 && has_command cargo && cargo --version >/dev/null 2>&1; }; then
    if [ "$DRY_RUN" = "true" ]; then
      echo "Would install Rust and Cargo via rustup (stable, minimal profile)."
    else
      # Official curl-based rustup installer; never use distro Rust packages.
      run_installer https://sh.rustup.rs sh -y --profile minimal --default-toolchain stable --no-modify-path
    fi
  fi

  # Older distribution packages lack the --zsh integration used by .zshrc.
  if ! { has_command fzf && fzf --zsh >/dev/null 2>&1; }; then
    if [ "$DRY_RUN" = "true" ]; then
      echo "Would install fzf with --zsh support into $fzf_dir."
    else
      clone_tool https://github.com/junegunn/fzf.git "$fzf_dir"
      bash "$fzf_dir/install" --bin
      link_binary "$fzf_dir/bin/fzf" fzf
    fi
  fi

  if ! has_command fnm; then
    if [ "$DRY_RUN" = "true" ]; then
      echo "Would install fnm into $FNM_DIR."
    else
      run_installer https://fnm.vercel.app/install bash --install-dir "$FNM_DIR" --skip-shell --force-no-brew
    fi
  fi
  if ! has_command node && ! { has_command fnm && fnm exec --using=default -- node --version >/dev/null 2>&1; }; then
    if [ "$DRY_RUN" = "true" ]; then
      echo "Would install Node.js LTS and set it as the fnm default."
    else
      fnm install --lts
      fnm default lts-latest
    fi
  fi

  if ! has_command zoxide; then
    if [ "$DRY_RUN" = "true" ]; then
      echo "Would install zoxide into $BIN_DIR."
    else
      run_installer https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh sh --bin-dir "$BIN_DIR"
    fi
  fi

  install_neovim
  if [ ! -f "$zinit_dir/zinit.zsh" ]; then
    if [ "$DRY_RUN" = "true" ]; then
      echo "Would clone Zinit into $zinit_dir (Zsh downloads its configured plugins on first launch)."
    else
      clone_tool https://github.com/zdharma-continuum/zinit.git "$zinit_dir"
    fi
  fi
}

check_dependencies() {
  local dependency
  local missing="false"
  echo "Checking dependencies for the installation script..."

  for dependency in git stow; do
    printf 'Checking availability of %s... ' "$dependency"
    if command -v "$dependency" >/dev/null 2>&1; then
      echo "OK!"
    else
      echo "Missing!"
      missing="true"
    fi
  done

  if [ "$missing" = "true" ]; then
    if [ "$DRY_RUN" = "true" ] && [ "$SKIP_DEPENDENCIES" != "true" ]; then
      echo "These dependencies would be installed before linking dotfiles."
      return
    fi
    echo "Not installing dotfiles due to missing dependencies." >&2
    exit 1
  fi
}

install_dotfiles() {
  local stow_args=(
    --dir="$INSTALL_DIR"
    --target="$HOME"
    --ignore='^(\.git|\.gitignore|scripts|README\.md|LICENSE\.md)$'
    --verbose
  )
  if [ "$DRY_RUN" = "true" ]; then
    if ! has_command stow || [ ! -d "$INSTALL_DIR/.config" ]; then
      echo "Would link dotfiles from $INSTALL_DIR into $HOME after installing dependencies."
      return
    fi
    stow_args+=(--simulate)
  fi

  # Stow checks all conflicts before making changes; never use --adopt here.
  stow "${stow_args[@]}" .
}

setup_shell() {
  local conf_file
  local current_shell="${SHELL:-}"
  echo "Dotfiles installed. Open a new terminal to apply the changes."
  case "${current_shell##*/}" in
  bash) conf_file="$HOME/.bashrc" ;;
  zsh) conf_file="$HOME/.zshrc" ;;
  *) return 0 ;;
  esac
  printf 'Or run: source %q\n' "$conf_file"
}

parse_args "$@"
check_os
export FNM_DIR
export PATH="$BIN_DIR:${CARGO_HOME:-$HOME/.cargo}/bin:$FNM_DIR:$PATH"
if [ "$SKIP_DEPENDENCIES" != "true" ]; then
  install_system_dependencies
  install_user_dependencies
fi
check_dependencies
download_dotfiles
install_dotfiles
if [ "$SKIP_SHELL" != "true" ] && [ "$DRY_RUN" != "true" ]; then
  setup_shell
fi
