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

For `bash`, `zsh` and `fish` shells, there's an [automatic installation script](./.ci/install.sh).

First ensure that `curl` and `unzip` are already installed on your operating system. Then execute:

```sh
curl -fsSL https://raw.githubusercontent.com/KorribanMaster/dotfiles/refs/heads/master/scripts/setup.sh | bash
```
