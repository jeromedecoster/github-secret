set -e

log() { echo -e "\e[38;5;82;4m${1}\e[0m \e[38;5;226m${@:2}\e[0m"; }
err() { echo -e "\e[38;5;196;4m${1}\e[0m \e[38;5;87m${@:2}\e[0m" >&2; }

download() {
    log download $1
    if [[ $2 == 'nosudo' ]]
    then
        curl $1 \
            --location \
            --remote-name \
            --progress-bar
    else
        sudo curl $1 \
            --location \
            --remote-name \
            --progress-bar
    fi
}

cd /usr/local/bin

# abort if already installed
[[ -x github-secret ]] && { err abort github-secret already exists; exit 0; }

# ask sudo accesss if not already available
if [[ -z $(sudo -n uptime 2>/dev/null) ]]; then
    log warn sudo access required
    sudo echo >/dev/null
    # one more check if the user abort the password question
    [[ -z `sudo -n uptime 2>/dev/null` ]] && { err abort sudo required; exit 1; }
fi

log install github-split
download raw.githubusercontent.com/jeromedecoster/github-secret/master/github-secret

sudo chmod +x github-secret

mkdir --parents ~/.config/github-secret
cd ~/.config/github-secret
download raw.githubusercontent.com/jeromedecoster/github-secret/master/README.md.tpl nosudo
download raw.githubusercontent.com/jeromedecoster/github-secret/master/script.sh.tpl nosudo

log installed github-secret
exit 0
