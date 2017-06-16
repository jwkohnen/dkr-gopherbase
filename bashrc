export PATH=/usr/local/go/bin:$PATH
export EDITOR=vim
eval $(ssh-agent -s) &> /dev/null
GIT_PROMPT_ONLY_IN_REPO=1 . ~/.bash-git-prompt/gitprompt.sh

# Ignore linter noise on Protobuffer generated sources and the most annoying
# golint warning. Deadline up to 5m, because ^C.
alias gometalinter="gometalinter --vendor -e'warning: exported .+ or be unexported \(golint\)' -e'.+\.pb\.go:.+' --deadline=5m"

alias antlr4='java -jar /usr/local/lib/antlr4-4.6-complete.jar'

command -V direnv &>/dev/null && eval "$(direnv hook bash)"
