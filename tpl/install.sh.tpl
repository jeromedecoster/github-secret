URL=https://raw.githubusercontent.com/jeromedecoster/{{REPOSITORY}}/master

log()   { echo -e "\e[30;47m ${1^^} \e[0m ${@:2}"; }
info()  { echo -e "\e[48;5;28m ${1^^} \e[0m ${@:2}"; }
warn()  { echo -e "\e[48;5;202m ${1^^} \e[0m ${@:2}" >&2; }
error() { echo -e "\e[48;5;196m ${1^^} \e[0m ${@:2}" >&2; }

CWD=$(pwd)
TEMP=$(mktemp --directory)

info decrypt secret
cd $TEMP

log download $URL/secret
if [[ -n $(which curl) ]]
then
    curl $URL/secret \
        --location \
        --remote-name \
        --progress-bar
else
    wget $URL/secret \
        --quiet \
        --show-progress
fi

log openssl decryption
openssl aes-256-cbc \
    -d \
    -a \
    -pbkdf2 \
    -iter 42 \
    -in secret \
    -out archive.zip
[[ $? == 1 ]] && { error fail openssl decryption error; exit; }

log unzip archive.zip
unzip archive.zip

# the zip file names on one line
CONTENT=$(unzip -l archive.zip \
    | tail -n +4 \
    | head -n -2 \
    | sed -E 's|^.*:[0-9]*\s*||' \
    | tr '\t' ' ')

# check if $CWD is writable by the user
if [[ -z $(sudo --user $(whoami) --set-home bash -c "[[ -w $CWD ]] && echo 1;") ]]
then
    warn warn sudo access is required
    sudo mv $CONTENT $CWD
else
    mv $CONTENT $CWD
fi

info decrypted $CONTENT

rm --force --recursive $TEMP
