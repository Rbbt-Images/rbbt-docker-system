#!/bin/bash -x

echo "RUNNING PROVISION"
echo
echo "CMD: build_rbbt_provision_sh.rb -Rc -Rp -sg -su -sb"
echo
echo -n "Starting: "
date

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
  openjdk-7-jdk \
  libcairo2 libcairo2-dev r-base-core r-base-dev r-cran-rserve liblzma5 liblzma-dev libcurl4-openssl-dev \
  libtokyocabinet-dev tokyocabinet-bin \
  build-essential zlib1g-dev libssl-dev libreadline6-dev libyaml-dev libffi-dev

# This link was broken for some reason
rm /usr/lib/R/bin/Rserve
ln -s /usr/lib/R/site-library/Rserve/libs/Rserve /usr/lib/R/bin/Rserve

grep R_HOME /etc/profile || echo "export R_HOME='/usr/lib/R' # For Ruby's RSRuby gem" >> /etc/profile
. /etc/profile


#!/bin/bash -x

# R INSTALL
# ============

cd /tmp

apt-get remove r-base-core

wget https://cran.r-project.org/src/base/R-3/R-3.3.2.tar.gz
tar -xvzf R-3.3.2.tar.gz

cd R-3.3.2/
./configure --prefix=/usr/local --enable-R-shlib
make && make install

grep -v R_HOME /etc/profile > profile.tmp
echo >> profile.tmp
echo "# For RSRuby gem " >> profile.tmp
echo "export R_HOME='/usr/local/lib/R'" >> profile.tmp
echo "export LD_LIBRARY_PATH=\"$LD_LIBRARY_PATH:$R_HOME/lib\"" >> profile.tmp
echo "export LD_RUN_PATH=\"$LD_RUN_PATH:$R_HOME/lib\"" >> profile.tmp
mv profile.tmp /etc/profile
. /etc/profile


echo "3. Setting up ruby"
#!/bin/bash -x

# RUBY INSTALL
# ============

cd /tmp
wget https://cache.ruby-lang.org/pub/ruby/2.3/ruby-2.3.1.tar.gz
tar -xvzf ruby-2.3.1.tar.gz
cd ruby-2.3.1/
./configure --prefix=/usr/local
make && make install

grep "#Ruby2" /etc/profile || echo 'export PATH="/usr/local/bin:$PATH" #Ruby2' >> /etc/profile
. /etc/profile



echo "3.1. Setting up gems"
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
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc /usr/share/man /usr/local/share/ri



echo
echo "Installation done."
date

