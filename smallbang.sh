#!/bin/bash

st3Version=3125_amd64
nvmVersion=v0.32.1
downloadDir=$(pwd)

echo "Decrypting confidential settings"
./crypto.sh -D
source <(grep -E '\w+=' .confidential/confidential.sh)

echo "Cleaning up Home"
cd ~ && rm -rf Templates/ Videos/ Examples/ Music/ Public/
mkdir wrkspc

echo "Grabbing GRUB customizer tool"
if [[ $(grep -q ^flags.*\ hypervisor /proc/cpuinfo) ]]; then
    echo "Nevermind this is a VM!"
else
    sudo add-apt-repository ppa:danielrichter2007/grub-customizer -y
    sudo apt-get update
    sudo apt-get install grub-customizer -y
fi

echo "Updating Git"
sudo add-apt-repository ppa:git-core/ppa -y
sudo apt-get update
sudo apt-get install git -y

echo "Setting Git global config"
git config --global core.editor subl
git config --global color.ui true
git config --global user.name ${nameForGithub}
git config --global user.email "${emailForGithub}"

echo "Generating a new SSH key and adding it to Github"
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -C ${emailForGithub} -P ""
eval "$(ssh-agent -s)" && ssh-add ~/.ssh/id_rsa
curl -u "${userForGithub}:${passForGithub}" --data "{\"title\":\"AutoKey_`date +%m%d%Y`\", \"key\":\"`cat ~/.ssh/id_rsa.pub`\"}" https://api.github.com/user/keys

echo "Grabbing microcosm Repo"
cd ~/wrkspc
git clone git@github.com:${userForGithub}/microcosm.git
cd microcosm
./crypto.sh -D
rm -rf ${downloadDir}

echo "Setting up .bashrc"
echo -e "\nalias nlg=\"npm list -g --depth=0 2>/dev/null\"" >> ~/.bashrc
echo -e "\nalias nll=\"npm list --depth=0 2>/dev/null\"" >> ~/.bashrc
echo -e "\ncd ~/wrkspc" >> ~/.bashrc

echo "Installing nvm and NodeJs"
sudo apt-get install build-essential libssl-dev -y
curl -o- https://raw.githubusercontent.com/creationix/nvm/${nvmVersion}/install.sh | bash
source ~/.bashrc
nvm install node

echo "Installing dev npm packages"
npm run globalDevpendencies

echo "Installing Sublime Text 3 dev build"
curl -o ~/Downloads/st3.deb https://download.sublimetext.com/sublime-text_build-${st3Version}.deb
sudo dpkg -i ~/Downloads/st3.deb
rm -f ~/Downloads/st3.deb

echo "Grabbing ST3 the license file"
sudo apt-get install xclip -y
cat .confidential/SublimeText3_License.txt | xclip -selection clipboard
echo "Apply the license (it's on your clipboard)"
subl

echo "Copying ST3 package and IDE settings"
curl -o ~/.config/sublime-text-3/Installed\ Packages/Package\ Control.sublime-package https://packagecontrol.io/Package%20Control.sublime-package
./sublsync.sh -P

echo "Installing Docker"
if [[ $(uname -m) == "x86_64" ]]; then
    sudo apt-get install linux-image-extra-$(uname -r) linux-image-extra-virtual apt-transport-https ca-certificates
    sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
    sudo apt-get update
    apt-cache policy docker-engine
    sudo apt-get install docker-engine
    sudo service docker start
    sudo groupadd docker
    sudo usermod -aG docker $USER
    sudo systemctl enable docker
    sudo docker run hello-world
else
    echo "Docker cannot be installed on x32 architectures"
fi

exit
