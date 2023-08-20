if status is-interactive
    # Commands to run in interactive sessions can go here
end

direnv hook fish | source
alias k='kubectl'

# Set PATH, MANPATH, etc., for Homebrew.
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
