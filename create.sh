#!/bin/bash
# Limited user creator
# Cretaed by Y.G., https://sys-adm.in

# Sys env / paths / etc
# -------------------------------------------------------------------------------------------\
PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
SCRIPT_PATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)

COMMANDS="$SCRIPT_PATH/commands.txt"

# Init
# ---------------------------------------------------\
# Help information
usage() {
    echo -e "Just set username without arguments: ./create.sh userName"
    exit 1
}

# Yes / No confirmation
confirm() {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure? [y/N]} " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        *)
            false
            ;;
    esac
}

# Get Actual date
getDate() {
  date '+%d-%m-%Y_%H-%M-%S'
}

# Setup or modify existing user
setup() {

    if [[ ! $1 ]]; then
        echo "Please set user name. Exit."
        usage
        exit 1
    else
        username=$1
    fi

    if [[ ! -f $COMMANDS ]]; then
        echo -e "Create commands file list: commands.txt. Exit."
        exit 1
    fi

    if [[ ! -d /home/$username/programs ]]; then
        mkdir -p /home/$username/programs
    else
        if confirm "User catalog exist. Recreate? (y/n or enter)"; then
            mv /home/$username /home/$username_bak_$(getDate)
            mkdir -p /home/$username/programs
        else
            echo -e "Operation declined. Exit."
            exit 1
        fi
    fi

    if [[ ! -f /bin/rbash ]]; then
        cp /bin/bash /bin/rbash
    fi

    if id "$1" &>/dev/null; then
        usermod -s /bin/rbash $username &>/dev/null
    else
        useradd -s /bin/rbash $username
    fi
    
    echo -e "if [ -f ~/.bashrc ]; then  
    . ~/.bashrc  
    fi  
 
    readonly PATH=\$HOME/programs  
    export PATH" > /home/$username/.bash_profile 

    # Read data from commands.txt
    while read -r command; do

        ln -s /bin/$command /home/$username/programs/

    done < $COMMANDS

    chattr +i /home/$username/.bash_profile

    echo -n "Enter password for $username: "
    read -s passwd

    echo $username:$passwd | sudo chpasswd

    echo -e "\nUser: $username with Password: $passwd created. Done!"
}

# Actions
# ---------------------------------------------------\
if [[ -z "$1" ]]; then
    usage
    exit 1
else
    setup $1
fi