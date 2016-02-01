#!/bin/bash -x

echo "RUNNING PROVISION"
echo
echo "CMD: ../rbbt-image/bin/build_rbbt_provision_sh.rb -sg -su -sb"

echo "1. Provisioning base system"
#!/bin/bash -x

# INSTALL
# =======

# Basic system requirements
# -------------------------
apt-get -y update
apt-get -y update
apt-get -y install \
  bison autoconf g++ libxslt1-dev make \
  zlib1g-dev libbz2-dev libreadline6 libreadline6-dev \
  wget curl git openssl libyaml-0-2 libyaml-dev \
  ruby2.0 ruby-dev \
  r-base-core r-base-dev r-cran-rserve \
  openjdk-7-jdk \
  libtokyocabinet-dev tokyocabinet-bin \
  build-essential zlib1g-dev libssl-dev libreadline6-dev libyaml-dev libffi-dev


grep R_HOME /etc/profile || echo "export R_HOME='/usr/lib/R' # For Ruby's RSRuby gem" >> /etc/profile
. /etc/profile

# This link was broken for some reason
rm /usr/lib/R/bin/Rserve
ln -s /usr/lib/R/site-library/Rserve/libs/Rserve /usr/lib/R/bin/Rserve


echo "2. Setting up ruby"
#!/bin/bash -x

# RUBY INSTALL
# ============

cd /tmp
wget http://ftp.ruby-lang.org/pub/ruby/2.1/ruby-2.1.5.tar.gz 
tar -xvzf ruby-2.1.5.tar.gz
cd ruby-2.1.5/
./configure --prefix=/usr/local
make && make install

grep "#Ruby2" /etc/profile || echo 'export PATH="/usr/local/bin:$PATH" #Ruby2' >> /etc/profile
. /etc/profile



echo "3. Setting up gems"
echo SKIPPED
echo

echo "4. Configuring user"
echo SKIPPED
echo

echo "5. Bootstrapping workflows as 'rbbt'"
echo
echo SKIPPED
echo

# CODA
# ====

apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

echo
echo "Installation done."
