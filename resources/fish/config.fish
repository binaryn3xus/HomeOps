if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -U fish_greeting ""
set PATH /home/linuxbrew/.linuxbrew/bin $PATH
/home/joshua/.local/bin/mise activate fish | source

alias k='kubecolor'
alias kubectl='kubecolor'
