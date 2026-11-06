# Ubuntu's /etc/zsh/zshrc runs compinit before ~/.zshrc, with an fpath that lacks
# ~/.config/zsh/completions. zinit runs compinit later, so skip the global one.
skip_global_compinit=1
