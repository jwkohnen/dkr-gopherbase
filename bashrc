export EDITOR=vim
eval $(ssh-agent -s) &> /dev/null

# Ignore linter noise on Protobuffer generated sources and the most annoying
# golint warning. Deadline up to 5m, because ^C.
alias gometalinter="gometalinter --vendor -e'warning: exported .+ or be unexported \(golint\)' -e'.+\.pb\.go:.+' --deadline=5m"
