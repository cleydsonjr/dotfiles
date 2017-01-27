#!/bin/bash
read -s -p "Usuário: " username
read -s -p "Senha padrão: " password

if [ ! $password ] ; then
	echo "Senha inválida"
	exit 1
else
	echo "Inciando execução. Senha='$password'"
fi

# Variáveis
versaoPostgres='9.5'
HOME="/home/$username"

# Criando diretório temporário
cd ~
mkdir temp
cd temp

echo "================================================================================"
echo "[$( date "+%Y/%m/%d %H:%M:%S" )] ADICIONANDO REPOSITÓRIOS E ATUALIZANDO"
echo "----------------------------------------------"
add-apt-repository -y ppa:webupd8team/java #Repositório para java
add-apt-repository ppa:jd-team/jdownloader #Repositório JDownloader

# ---------------Repositório PostgresSQL--------------------
PGDG_LIST='/etc/apt/sources.list.d/pgdg.list'
REPOSITORIO="deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -suc)-pgdg main"
touch "$PGDG_LIST"
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
# -------------Fim Repositório PostgresSQL-------------------

# -------------Repositório Google Chrome---------------------
GOOGLE_CHROME_LIST='/etc/apt/sources.list.d/google-chrome.list'
REPOSITORIO="deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main"
touch "$GOOGLE_CHROME_LIST"
echo "$REPOSITORIO" | tee -a "$GOOGLE_CHROME_LIST"
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
# -------------Fim Repositório Google Chrome---------------------

# -------------Repositório Skype---------------------
SKYPE_LIST="/etc/apt/sources.list.d/skype.list"
REPOSITORIO="deb http://archive.canonical.com/ $(lsb_release -suc) partner"
touch "$SKYPE_LIST"
echo "$REPOSITORIO" | tee -a "$SKYPE_LIST"
# -------------Repositório Skype---------------------

sed -i "/^# deb .*partner/ s/^# //" /etc/apt/sources.list
add-apt-repository -y ppa:mpstark/elementary-tweaks-daily
add-apt-repository -y ppa:diodon-team/stable

apt-get update
apt-get upgrade

echo "================================================================================"
echo "[$( date "+%Y/%m/%d %H:%M:%S" )] APLICATIVOS ESSENCIAIS"
echo "----------------------------------------------"
apt-get install -y p7zip-rar p7zip-full unace unrar zip unzip sharutils rar
apt-get install -y vim
apt-get install -y curl
apt-get install -y xclip
apt-get install -y openssh-server
apt-get install -y sshpass
apt-get install -y nmap
apt-get install -y nmon
apt-get install -y fcitx
apt-get install -y zram-config
apt-get install -y htop
apt-get install -y gparted
apt-get install -y gnome-disk-utility
apt-get install -y dconf-tools
apt-get install -y elementary-tweaks
apt-get install -y ubuntu-restricted-extra
apt-get install -y diodon


echo "================================================================================"
echo "[$( date "+%Y/%m/%d %H:%M:%S" )] GOOGLE CHROME"
echo "----------------------------------------------"
sudo apt-get install -y google-chrome-stable

echo "================================================================================"
echo "[$( date "+%Y/%m/%d %H:%M:%S" )] JAVA 7 e 8"
echo "----------------------------------------------"
apt-get install oracle-jdk7-installer -y
apt-get install oracle-java8-installer -y

echo "================================================================================"
echo "[$( date "+%Y/%m/%d %H:%M:%S" )] JDOWNLOADER"
echo "----------------------------------------------"
apt-get install jdownloader -y

echo "================================================================================"
echo "[$( date "+%Y/%m/%d %H:%M:%S" )] GIT"
echo "----------------------------------------------"
apt-get install -y git

echo "================================================================================"
echo "[$( date "+%Y/%m/%d %H:%M:%S" )] POSTGRESQL"
echo "----------------------------------------------"
apt-get install -y postgresql-${versaoPostgres} postgresql-server-dev-${versaoPostgres} postgresql-contrib-${versaoPostgres} pgadmin3
sudo -u postgres psql --command="ALTER USER postgres WITH PASSWORD '$password';"

echo "================================================================================"
echo "[$( date "+%Y/%m/%d %H:%M:%S" )] MYSQL"
echo "----------------------------------------------"
apt-get install -y mysql-client mysql-server
mysqladmin -u root password $password

echo "================================================================================"
echo "[$( date "+%Y/%m/%d %H:%M:%S" )] REDIS"
echo "----------------------------------------------"
apt-get -y install redis-server

echo "================================================================================"
echo "[$( date "+%Y/%m/%d %H:%M:%S" )] SKYPE"
echo "----------------------------------------------"
apt-get install -y skype

echo "================================================================================"
echo "[$( date "+%Y/%m/%d %H:%M:%S" )] BYOBU"
echo "----------------------------------------------"
sudo apt-get install -y byobu

echo "================================================================================"
echo "[$( date "+%Y/%m/%d %H:%M:%S" )] SDKMAN"
echo "----------------------------------------------"
curl -s "https://get.sdkman.io" | sudo -u $username bash

SYSCTL_CONFIG=$( cat << EOF
vm.swappiness=10
fs.inotify.max_user_watches = 524288
EOF
)
echo "$SYSCTL_CONFIG" | tee -a '/etc/sysctl.conf'
sysctl -p > /dev/null

LIMITS_CONF='/etc/security/limits.conf'
CONFIGURACAO_FILES=$( cat << EOF
*  soft  nofile 9000
*  hard  nofile 65000
EOF
)
echo "$CONFIGURACAO_FILES" | tee -a "$LIMITS_CONF"

COMMON_SESSION='/etc/pam.d/common-session'
CONFIGURACAO_SESSION=$( cat << EOF
session required pam_limits.so
EOF
)
echo "$CONFIGURACAO_SESSION" | tee -a "$COMMON_SESSION"

echo "================================================================================"
echo "[$( date "+%Y/%m/%d %H:%M:%S" )] INTELLIJ IDEA"
echo "----------------------------------------------"
NOME='Intellij Idea'
VERSAO_DESEJADA="2016.1.3"
BUILD_DESEJADA="IU-145.1617.8"
URL_DOWNLOAD="https://download.jetbrains.com/idea/ideaIU-${VERSAO_DESEJADA}.tar.gz"

PASTA_INSTALACAO="${HOME}/idea"
echo "Baixando ${NOME} ${VERSAO_DESEJADA}"
mkdir -p "${PASTA_INSTALACAO}"
wget -O - "${URL_DOWNLOAD}" | tar xz --strip=1 -f -  -C "${PASTA_INSTALACAO}"

VERSAO=2016.1.3
NOME_APLICACAO="IntelliJ IDEA"
PASTA=${HOME}/idea
ARQUIVO_CONFIGURACAO="${HOME}/.local/share/applications/intellijidea.desktop"

CONTEUDO_CONFIGURACAO=$( cat << EOF
#!/usr/bin/env xdg-open
[Desktop Entry]
Version=${VERSAO}
Type=Application
Terminal=false
Exec=${PASTA}/bin/idea.sh
Name=${NOME_APLICACAO} ${VERSAO}
Icon=${PASTA}/bin/idea.png
StartupWMClass=jetbrains-idea
EOF
)
sudo touch "$ARQUIVO_CONFIGURACAO"
sudo rm -f $ARQUIVO_CONFIGURACAO
echo "$CONTEUDO_CONFIGURACAO" | sudo tee -a "$ARQUIVO_CONFIGURACAO"

echo "================================================================================"
echo "[$( date "+%Y/%m/%d %H:%M:%S" )] OBTENDO DOTFILES"
echo "----------------------------------------------"
sudo -u $username mkdir -p ~/workspace/cleydsonjr/
sudo -u $username git clone git@github.com:cleydsonjr/dotfiles.git $HOME/workspace/cleydsonjr/dotfiles
sudo -u $username ln -s $HOME/workspace/cleydsonjr/dotfiles/.gitconfig ~/

cd ~
rm -rf temp