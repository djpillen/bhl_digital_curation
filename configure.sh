#!/usr/bin/env bash

echo "Updating and installing dependencies"
add-apt-repository -y ppa:stebbins/handbrake-releases
apt-get -y update && apt-get -y upgrade
apt -y install autoconf automake build-essential cifs-utils ffmpeg git git-core handbrake-cli libtool openjdk-8-jdk p7zip-full python3-pip python3-venv sqlite3 unzip

echo "Setting up Python virtual environment"
mkdir -p /usr/share/bhl_digital_curation/virtualenvs
cd /usr/share/bhl_digital_curation/virtualenvs
python3 -m venv venv
chown -R vagrant:vagrant /usr/share/bhl_digital_curation

# https://github.com/timothyryanwalsh/brunnhilde
cd /home/vagrant
echo "Installing Siegfried"
wget -qO - https://bintray.com/user/downloadSubjectPublicKey?username=bintray | apt-key add -
echo "deb http://dl.bintray.com/siegfried/debian wheezy main" | tee -a /etc/apt/sources.list
apt-get -y update && apt-get -y install siegfried

echo "Installing bulk_extractor"
cd /home/vagrant
git clone --recursive https://github.com/simsong/bulk_extractor.git
cd bulk_extractor
bash etc/CONFIGURE_UBUNTU18LTS.bash
echo "continue"
chmod +x bootstrap.sh
./bootstrap.sh
./configure
make
make install

echo "Installing HFSExplorer"
cd /home/vagrant
mkdir zips
cd zips
wget -q https://sourceforge.net/projects/catacombae/files/HFSExplorer/0.23.1%20%28snapshot%202016-09-02%29/hfsexplorer-0.23.1-snapshot_2016-09-02-bin.zip/download -O hfsexplorer.zip
mkdir /usr/share/hfsexplorer
unzip hfsexplorer.zip -d /usr/share/hfsexplorer/

echo "Installing Sleuthkit"
apt install -y sleuthkit

echo "Installing ClamAV"
apt install -y clamav
/etc/init.d/clamav-freshclam stop
freshclam

echo "Installing tree"
apt install -y tree

echo "Installing Brunnhilde"
/usr/share/bhl_digital_curation/virtualenvs/venv/bin/pip install brunnhilde

echo "Installing aip-repackaging scripts"
/usr/share/bhl_digital_curation/virtualenvs/venv/bin/pip install git+https://github.com/bentley-historical-library/bhlaspaceapiclient.git
/usr/share/bhl_digital_curation/virtualenvs/venv/bin/pip install git+https://github.com/bentley-historical-library/DAPPr.git
/usr/share/bhl_digital_curation/virtualenvs/venv/bin/pip install git+https://github.com/djpillen/aip-repackaging.git

echo "Installing bhl_born_digital_utils"
mkdir /usr/lib/bhl_born_digital_utils
cd /usr/lib/bhl_born_digital_utils
git clone https://github.com/bentley-historical-library/bhl_born_digital_utils.git .
/usr/share/bhl_digital_curation/virtualenvs/venv/bin/pip install -r requirements.txt

echo "Installing Archivematica automation-tools"
mkdir /usr/lib/automation-tools
cd /usr/lib/automation-tools
git clone https://github.com/djpillen/automation-tools.git .
/usr/share/bhl_digital_curation/virtualenvs/venv/bin/pip install -r requirements.txt

chown -R vagrant:vagrant /usr/lib/bhl_born_digital_utils
chown -R vagrant:vagrant /usr/lib/automation-tools
chown -R vagrant:vagrant /usr/share/bhl_digital_curation

echo "Creating symbolic links"
ln -s /vagrant/secrets/.aspaceapi /home/vagrant/.aspaceapi
ln -s /vagrant/secrets/.dappr /home/vagrant/.dappr
ln -s /vagrant/secrets/.automation-tools /home/vagrant/.automation-tools

echo "Configuring fstab"
cat /vagrant/secrets/fstab.txt | tee -a /etc/fstab

echo "Adding virtualenv to bashrc"
echo "source /usr/share/bhl_digital_curation/virtualenvs/venv/bin/activate" >> /home/vagrant/.bashrc

echo "Cleaning up"
cd /home/vagrant
rm -rf /home/vagrant/zips
rm -rf /home/vagrant/bulk_extractor