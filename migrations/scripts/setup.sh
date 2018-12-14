#!/bin/bash -e

################################# SCRIPT SETUP #################################

trap 'echo "AN ERROR OCCURRED. PLEASE CHECK OUTPUT FOR MORE INFO."' ERR

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

################################ CONFIGURE SSH #################################

if [ ! -f ~/.ssh/known_hosts ]
then
  ssh-keyscan -H github.com >> ~/.ssh/known_hosts
fi

if [ ! -f ~/.ssh/id_rsa ]
then
  ssh-keygen -t rsa -b 4096 -N '' -f ~/.ssh/id_rsa
  echo 'Created the following ssh keys (add it to Github > settings):'
  cat ~/.ssh/id_rsa.pub
  echo 'Once you are done, hit any key ton continue the setup...'
  read line

  if man ssh-add | grep -e '-K' > /dev/null 2>&1
  then
    # Configure ssh-add to use Macosx KeyChain
    SSH_ADD_CMD='ssh-add -K ~/.ssh/id_rsa > /dev/null 2>&1'
    eval "${SSH_ADD_CMD}"

    if ! grep -e "${SSH_ADD_CMD}" ~/.bashrc > /dev/null
    then echo "${SSH_ADD_CMD}" >> ~/.bashrc
    fi

    if ! grep -e "${SSH_ADD_CMD}" ~/.zshrc > /dev/null
    then echo "${SSH_ADD_CMD}" >> ~/.zshrc
    fi
  elif [ -x '/usr/lib/git-core/git-credential-libsecret' ]
  then
    git config --global credential.helper '/usr/lib/git-core/git-credential-libsecret'
  # elif [ -x '/usr/lib/git-core/git-credential-gnome-keyring' ]
  # then
  #   git config --global credential.helper '/usr/lib/git-core/git-credential-gnome-keyring'
  else
    echo 'Unable to configure your ssh agent. You will need to add the key manually.'
  fi
fi

############################ CONFIGURE SHELL ALIASES ###########################

if [ -d ~/.oh-my-zsh/custom ]
then cp "${SCRIPTS_DIR}/aliases.sh" ~/.oh-my-zsh/custom/docker-compose.zsh
elif ! grep -e "source ${SCRIPTS_DIR}/aliases.sh" ~/.zshrc > /dev/null
then echo "source ${SCRIPTS_DIR}/aliases.sh" >> ~/.zshrc
fi

if ! grep -e "source ${SCRIPTS_DIR}/aliases.sh" ~/.bashrc > /dev/null
then echo "source ${SCRIPTS_DIR}/aliases.sh" >> ~/.bashrc
fi

########################### CHECKOUT SUB DIRECTORIES ###########################

############################# CONFIGURE THIS REPO ##############################

if [ ! -e "./env/local.env" ]
then touch "./env/local.env"
fi

################################ PREPARE BUILD #################################

docker-compose stop
docker-compose pull

################################ BUILD FLASK APP ################################


################################### CLEANUP ####################################

docker-compose stop

##################################### NODE #####################################

npm install

##################################### DONE #####################################

echo "\n\nDONE: You can now start the apps: 'dup client-app', 'dup manager-app', ...\n\n"
