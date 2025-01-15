echo "
╭────────────────────────────────────────────────────────╮
│ ███╗   ██╗███████╗ ██████╗██████╗  ██████╗ ███╗   ███╗ │
│ ████╗  ██║██╔════╝██╔════╝██╔══██╗██╔═══██╗████╗ ████║ │
│ ██╔██╗ ██║█████╗  ██║     ██████╔╝██║   ██║██╔████╔██║ │
│ ██║╚██╗██║██╔══╝  ██║     ██╔══██╗██║   ██║██║╚██╔╝██║ │
│ ██║ ╚████║███████╗╚██████╗██║  ██║╚██████╔╝██║ ╚═╝ ██║ │
│ ╚═╝  ╚═══╝╚══════╝ ╚═════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝ │
╰────────────────────────────────────────────────────────╯
"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
#
#
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

export ZVM_INIT_MODE=sourcing
GITSTATUS_LOG_LEVEL=DEBUG
# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-autosuggestions zsh-vi-mode docker)
# plugins+=(zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

export EDITOR="nvim"

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
# alias vim="nvim"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
#source /home/diogo/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# source /Users/dferreir/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

alias vim="nvim"
alias e="nvim"
alias ls='lsd --color never'
alias ll='ls -l'
alias la='ls -A'
alias lla='ls -lA'
alias lt='ls --tree'
alias brew="~/.linuxbrew/bin/brew"
function x() {
	echo $PWD > ~/.scripts/lastdir_vifm
	vifm
	cd "$(cat ~/.scripts/lastdir_vifm)"
}
# alias vifm="x"
alias lazygit="~/.linuxbrew/bin/lazygit"
alias g="~/.linuxbrew/bin/lazygit"
alias y="yadm enter lazygit"
alias cwd.sh="source ~/42/Scripts/cwd.sh"
alias copy_selected.sh="source ~/42/Scripts/copy_selected.sh"
alias z="source ~/.zshrc && echo '[ZSH Reloaded]'"
alias m='cmatrix'
# alias composer='~/.brew/Cellar/composer.phar'
# alias ripgrep='~/.brew/Cellar/rg'
# alias rg='~/.brew/Cellar/rg'

#RANGER
# function ranger_cd {
#     local IFS=$'\t\n'
#     local tempfile="$(mktemp -t tmp.XXXXXX)"
#     local ranger_cmd=(
#         command
#         ~/Library/Python/2.7/bin/ranger
#         --cmd="map Q chain shell echo %d > "$tempfile"; quitall"
#     )
#
#     ${ranger_cmd[@]} "$@"
#     if [[ -f "$tempfile" ]] && [[ "$(cat -- "$tempfile")" != "$(echo -n `pwd`)" ]]; then
#         cd -- "$(cat "$tempfile")" || return
#     fi
#     command rm -f -- "$tempfile" 2>/dev/null
# }
#
# alias ranger=ranger_cd

#alias ranger="Library/Python/2.7/bin/ranger"
#alias r="Library/Python/2.7/bin/ranger"

# //VI MODE//
bindkey -v
bindkey '^k' up-line-or-beginning-search
bindkey '^j' down-line-or-beginning-search
bindkey '^h' vi-backward-char
bindkey '^l' vi-forward-char
bindkey '^x' clear-screen

# Yank to the system clipboard
function vi-yank-xclip {
    zle vi-yank
   echo "$CUTBUFFER" | pbcopy -i
}
# zle -N vi-yank-xclbindkey -M vicmd 'y' vi-yank-xclip
# bindkey -M vicmd 'y' vi-yank-xclip

ZVM_VI_HIGHLIGHT_FOREGROUND=#FF0000
ZVM_VI_HIGHLIGHT_BACKGROUND=#600000

# //ZSH-AUTOSUGGESTIONS//
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#800000"
ZSH_AUTOSUGGEST_STRATEGY=completion
eval "$(/root/.linuxbrew/bin/brew shellenv)"

export HTTP_PROXY="http://p-proxy-01.cp.loc:3128"
export HTTPS_PROXY="http://p-proxy-01.cp.loc:3128"
export NO_PROXY="localhost,127.0.0.1,.loc"
