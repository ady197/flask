#!/bin/bash -e

trap 'echo "AN ERROR OCCURRED. PLEASE CHECK OUTPUT FOR MORE INFO."' ERR

if ! pkgutil --pkg-info=com.apple.pkg.CLTools_Executables > /dev/null 2>&1
then
  xcode-select --install
  read -p 'Hit [enter] once the command line tools are installed'
fi

if ! [ -x "$(command -v brew)" ]
then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

sudo mkdir -p "/usr/local/sbin"
sudo chown `id -u`:`id -g` "/usr/local/sbin"

brew update
brew tap codekitchen/dinghy

export HOMEBREW_NO_AUTO_UPDATE=1
brew install dinghy
brew install docker
brew install docker-compose
brew install docker-machine
brew install docker-machine-nfs
brew install --force-bottle docker-machine-driver-xhyve
brew install xhyve

brew unlink unfs3 || true
brew link unfs3
brew cleanup
brew doctor || true

sudo chown root:wheel $(brew --prefix)/opt/docker-machine-driver-xhyve/bin/docker-machine-driver-xhyve
sudo chmod u+s $(brew --prefix)/opt/docker-machine-driver-xhyve/bin/docker-machine-driver-xhyve

if ! docker-machine ls | grep dinghy > /dev/null 2>&1
then
  echo 'Creating a Dinghy virtual machine'

  read -p 'CPUs [3]: ' cpus
  read -p 'RAM [4096]: ' memory
  read -p 'Disk size (MB) [40000]: ' disk
  dinghy create --provider=xhyve --cpus=${cpus:-3} --memory=${memory:-4096} --disk=${disk:-40000}
fi

if [ -d ~/.oh-my-zsh/custom ]
then
  echo 'Configuring Oh-my-zsh'
  dinghy env > ~/.oh-my-zsh/custom/dinghy.zsh
elif [ ! -z "${ZSH_NAME}" ]
then
  echo 'Configuring ZSH'
  sed -i -e '/DOCKER_/d' ~/.zshrc
  dinghy env >> ~/.zshrc
elif [ ! -z "${BASH}" ]
then
  echo 'Configuring BASH'
  sed -i -e '/DOCKER_/d' ~/.bashrc
  dinghy env >> ~/.bashrc
else
  echo 'Unable to configure your shell' >&2
  exit 1
fi

if ! grep ':dinghy_domain: "local"' ~/.dinghy/preferences.yml > /dev/null
then
  echo 'Configuring Dinghy'

  sed -i -e 's/:preferences: {}/:preferences:\'$'\n  :dinghy_domain: "local"/g' ~/.dinghy/preferences.yml
  sed -i -e 's/:dinghy_domain: .*$/:dinghy_domain: "local"/g' ~/.dinghy/preferences.yml
  if ! grep ':dinghy_domain:' ~/.dinghy/preferences.yml > /dev/null
  then sed -i -e 's/:preferences:$/:preferences:\'$'\n  :dinghy_domain: "local"/g' ~/.dinghy/preferences.yml
  fi

  if ! grep ':dinghy_domain: "local"' ~/.dinghy/preferences.yml > /dev/null
  then
    echo 'ERROR: Unable to configure Dinghy' >&2
    echo 'Make sure that the dinghy preferences file (~/.dinghy/preferences.yml) contains at least the ":dinghy_domain: "local"" line, under ":preferences:".' >&2
    exit 1
  fi

  dinghy restart
fi

# if ! [ -e "${HOME}/.dinghy/certs/.sortlist.local.crt" ]
# then
#   echo 'Creating self-signed wildcart certificate'

#   mkdir -p "${HOME}/.dinghy/certs/"
#   openssl req -x509 -newkey rsa:2048 -keyout "${HOME}/.dinghy/certs/.sortlist.local.key" \
#     -out "${HOME}/.dinghy/certs/.sortlist.local.crt" -days 365 -nodes \
#     -subj "/C=BE/ST=Wallonia/L=Wavre/O=Sortlist S.A./OU=Product/CN=*.sortlist.local" \
#     -config <(cat /etc/ssl/openssl.cnf <(printf "[SAN]\nsubjectAltName=DNS:*.sortlist.local")) \
#     -reqexts SAN -extensions SAN
# fi
