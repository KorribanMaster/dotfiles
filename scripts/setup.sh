#!/bin/bash

set -e

RELEASE="latest"
OS="$(uname -s)"

case "${OS}" in
   MINGW* | Win*) OS="Windows" ;;
esac

if [ -d "$HOME/.fnm" ]; then
  INSTALL_DIR="$HOME/dotfiles"
elif [ -n "$XDG_DATA_HOME" ]; then
  INSTALL_DIR="$XDG_DATA_HOME/dotfiles"
elif [ "$OS" = "Darwin" ]; then
  INSTALL_DIR="$HOME/dotfiles"
else
  INSTALL_DIR="$HOME/dotfiles"
fi

# Parse Flags
parse_args() {
  while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
    -d | --install-dir)
      INSTALL_DIR="$2"
      shift # past argument
      shift # past value
      ;;
    --force-install | --force-no-brew)
      echo "\`--force-install\`: I hope you know what you're doing." >&2
      FORCE_INSTALL="true"
      shift
      ;;
    *)
      echo "Unrecognized argument $key"
      exit 1
      ;;
    esac
  done
}

set_filename() {
  if [ "$OS" = "Linux" ]; then
    echo "Downloading the latest dotfiles from GitHub..."
  else
    echo "OS $OS is not supported."
    exit 1
  fi
}

download_dotfiles() {
  URL="https://github.com/KorribanMaster/dotfiles.git"
  echo "Cloning $URL..."
  mkdir -p "$INSTALL_DIR" &>/dev/null
  git clone $URL $INSTALL_DIR

}

check_dependencies() {
  echo "Checking dependencies for the installation script..."

  echo -n "Checking availability of git... "
  if hash git 2>/dev/null; then
    echo "OK!"
  else
    echo "Missing!"
    SHOULD_EXIT="true"
  fi

  echo -n "Checking availability of stow... "
  if hash stown 2>/dev/null; then
    echo "OK!"
  else
    echo "Missing!"
    SHOULD_EXIT="true"
  fi

  if [ "$SHOULD_EXIT" = "true" ]; then
    echo "Not installing dotfiles due to missing dependencies."
    exit 1
  fi
}

ensure_containing_dir_exists() {
  local CONTAINING_DIR
  CONTAINING_DIR="$(dirname "$1")"
  if [ ! -d "$CONTAINING_DIR" ]; then
    echo " >> Creating directory $CONTAINING_DIR"
    mkdir -p "$CONTAINING_DIR"
  fi
}

setup_shell() {
  CURRENT_SHELL="$(basename "$SHELL")"

  if [ "$CURRENT_SHELL" = "zsh" ]; then
    CONF_FILE=${ZDOTDIR:-$HOME}/.zshrc
    ensure_containing_dir_exists "$CONF_FILE"
    echo "Installing for Zsh."

  elif [ "$CURRENT_SHELL" = "fish" ]; then
    CONF_FILE=$HOME/.config/fish/conf.d/fnm.fish
    ensure_containing_dir_exists "$CONF_FILE"
    echo "Installing for fish."

  elif [ "$CURRENT_SHELL" = "bash" ]; then
    if [ "$OS" = "Darwin" ]; then
      CONF_FILE=$HOME/.profile
    else
      CONF_FILE=$HOME/.bashrc
    fi
    ensure_containing_dir_exists "$CONF_FILE"
    echo "Installing for Bash."

  else
    echo "Could not infer shell type. Please set up manually."
    exit 1
  fi

  echo ""
  echo "In order to apply the changes, open a new terminal or run the following command:"
  echo ""
  echo "  source $CONF_FILE"
}

parse_args "$@"
set_filename
check_dependencies
download_dotfiles
cd $INSTALL_DIR && stow . --addopt || cd -
if [ "$SKIP_SHELL" != "true" ]; then
  setup_shell
fi

