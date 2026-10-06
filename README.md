# Dotfiles

This is my dotfiles directory to use it you have to install stow 

```shell
sudo apt install stow
```

To create the symlinks eg for vim you have to do the following
* delete or backup original dotfiles in your home directory
* `stow`

## Creation of new pkgs

You have to maintain the original folder structure. 

Watch this [video](https://www.youtube.com/watch?v=y6XCebnB9gs&t=79s)

## Installation

### Using a script (macOS/Linux)

There's an [automatic installation script](./scripts/setup.sh) for macOS and Linux.

From an existing checkout, run as your normal user (not with `sudo`):

```sh
bash scripts/setup.sh
```

The script installs missing dependencies, reuses the checkout, and links the
dotfiles into your home directory. System packages use `apt-get`, `dnf`, or
`pacman` on Linux (with `sudo` when needed). macOS requires [Homebrew](https://brew.sh).
Ubuntu/Debian derivatives use `apt-get`; Arch derivatives use `pacman`.
On Arch, keep your system up to date with your normal full-system upgrade before
setup; the script does not refresh only the package database or upgrade your
whole system automatically.

Dependencies include:

* Git, Stow, curl, unzip, tar/gzip, Zsh, tmux, Vim, OpenSSH, ripgrep, fd, Python 3,
  and C build tools.
* Rust/Cargo via the official curl-downloaded `https://sh.rustup.rs` installer,
  using the stable toolchain and minimal profile (not distribution Rust packages).
* fzf with `--zsh` integration, fnm, and Node.js LTS when Node is missing.
* zoxide, stable Neovim >= 0.11, and Zinit. Zinit downloads Powerlevel10k and the
  configured Zsh plugins/snippets on the first Zsh launch.

User tools are installed under `~/.local`, `~/.cargo`, or `$XDG_DATA_HOME` where
applicable, using their upstream installers/releases. Installers do not edit
your shell configuration. Existing usable tools are skipped; old fzf/Neovim
versions are supplemented with user-local versions, not uninstalled.

Existing files are not overwritten: back up any conflicting files first.
Use `--dry-run` to preview installs and symlink changes without downloading,
installing, or cloning anything. Use `--skip-dependencies` to only link dotfiles,
or `--install-dir DIR` to select a checkout.

Docker, Conda, ESP-IDF (`~/export-esp.sh`), and WSL browser integration (`wslview`)
remain optional and are not installed. The Oh My Zsh Docker snippet does not
require Docker to start your shell. No login-shell change is made automatically;
run `zsh` to try the configuration. Language servers and additional Neovim plugin
tools remain managed separately (for example, via Mason).

To download and install instead, ensure `curl` is also installed and execute:

```sh
curl -fsSL https://raw.githubusercontent.com/KorribanMaster/dotfiles/refs/heads/master/scripts/setup.sh | bash
```

### Testing

Run the offline installer tests (no downloads or real package installations):

```sh
python3 -B -m unittest discover -s scripts/tests -v
```
