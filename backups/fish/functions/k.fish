function k --wraps=kubectl --description 'kubectl shorthand'
    if type -q kubecolor
        kubecolor $argv
    else
        kubectl $argv
    end
end
