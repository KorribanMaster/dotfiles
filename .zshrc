# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmation,s etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname "$ZINIT_HOME")"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
if [[ -f "${ZINIT_HOME}/zinit.zsh" ]]; then
  source "${ZINIT_HOME}/zinit.zsh"

  # Add in Powerlevel10k
  zinit ice depth=1; zinit light romkatv/powerlevel10k

  # Add in zsh plugins
  zinit light zsh-users/zsh-syntax-highlighting
  zinit light zsh-users/zsh-completions
  zinit light zsh-users/zsh-autosuggestions
  zinit light Aloxaf/fzf-tab

  # Add in snippets
  zinit snippet OMZL::git.zsh
  zinit snippet OMZP::git
  zinit snippet OMZP::sudo
  zinit snippet OMZP::docker
  zinit snippet OMZP::tmux
  zinit snippet OMZP::ssh
  zinit snippet OMZP::web-search
  zinit snippet OMZP::command-not-found

fi

# Load completions, even when Zinit is unavailable.
autoload -Uz compinit && compinit
if command -v zinit >/dev/null 2>&1; then
  zinit cdreplay -q
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Aliases
alias ls='ls --color'
alias ll="ls -lah --color"
alias c='clear'
alias e="$EDITOR"

# Path
export PATH="$HOME/.opencode/bin:$PATH"

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi
[ -f "${CARGO_HOME:-$HOME/.cargo}/env" ] && source "${CARGO_HOME:-$HOME/.cargo}/env"
[ -f "$HOME/export-esp.sh" ] && source "$HOME/export-esp.sh"

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
   if command -v wslview >/dev/null 2>&1; then
      export BROWSER='wslview'
   elif command -v xdg-open >/dev/null 2>&1; then
      export BROWSER='xdg-open'
   elif command -v open >/dev/null 2>&1; then
      export BROWSER='open'
   fi
fi

export XDG_CONFIG_HOME="$HOME/.config/"
# Shell integrations
if command -v fzf >/dev/null 2>&1 && fzf --zsh >/dev/null 2>&1; then
    eval "$(fzf --zsh)"
elif [ -f "$HOME/.fzf.zsh" ]; then
    source "$HOME/.fzf.zsh"
fi
if [[ "$CLAUDECODE" != "1" ]] && command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init --cmd cd zsh)"
fi
# fnm
FNM_PATH="${FNM_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/fnm}"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
fi
if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --fnm-dir "$FNM_PATH" --shell zsh --use-on-cd)"
fi
if [ -x "$HOME/miniconda3/bin/conda" ]; then
   eval "$("$HOME/miniconda3/bin/conda" shell.zsh hook)"
fi
export GPG_TTY=$(tty)
