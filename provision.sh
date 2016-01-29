cat "$0"
echo "Running provisioning"
echo

# BASE SYSTEM
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



# BASE SYSTEM
echo "2. Setting up ruby"
#!/bin/bash -x

# Ruby gems and Rbbt
# -------------------------

cd /tmp
wget http://ftp.ruby-lang.org/pub/ruby/2.1/ruby-2.1.5.tar.gz 
tar -xvzf ruby-2.1.5.tar.gz
cd ruby-2.1.5/
./configure --prefix=/usr/local
make && make install

grep "#Ruby2" /etc/profile || echo 'export PATH="/usr/local/bin:$PATH" #Ruby2' >> /etc/profile
. /etc/profile



# BASE SYSTEM
echo "2. Setting up gems"


exit

####################
# USER CONFIGURATION

if [[ 'rbbt' == 'root' ]] ; then
  home_dir='/root'
else
  useradd -ms /bin/bash rbbt
  home_dir='/home/rbbt'
fi

user_script=$home_dir/.rbbt/bin/provision
mkdir -p $(dirname $user_script)
chown -R rbbt /home/rbbt/.rbbt/
cat > $user_script <<'EUSER'

. /etc/profile

echo "2.1. Custom variables"
export RBBT_LOG="0"
export BOOTSTRAP_WORKFLOWS="Enrichment Translation Sequence MutationEnrichment"
export REMOTE_RESOURCES="KEGG"

echo "2.2. Default variables"
#!/bin/bash -x

test -z ${RBBT_SERVER+x}           && RBBT_SERVER=http://rbbt.bioinfo.cnio.es/ 
test -z ${RBBT_FILE_SERVER+x}      && RBBT_FILE_SERVER="$RBBT_SERVER"
test -z ${RBBT_WORKFLOW_SERVER+x}  && RBBT_WORKFLOW_SERVER="$RBBT_SERVER"

test -z ${REMOTE_RESOURCES+x}  && REMOTE_RESOURCES="Organism ICGC COSMIC KEGG InterPro"
test -z ${REMOTE_WORFLOWS+x}   && REMOTE_WORFLOWS=""

test -z ${RBBT_WORKFLOW_AUTOINSTALL+x}  && RBBT_WORKFLOW_AUTOINSTALL="true"

test -z ${WORKFLOWS+x}  && WORKFLOWS=""

test -z ${BOOTSTRAP_WORKFLOWS+x}  && BOOTSTRAP_WORKFLOWS=""
test -z ${BOOTSTRAP_CPUS+x}       && BOOTSTRAP_CPUS="2"

test -z ${RBBT_LOG+x}  && RBBT_LOG="LOW"



echo "2.3. Configuring rbbt"
#!/bin/bash -x

# GENERAL
# -------

# File servers: to speed up the production of some resources
for resource in $REMOTE_RESOURCES; do
    echo "Adding remote file server: $resource -- $RBBT_FILE_SERVER"
    rbbt file_server add $resource $RBBT_FILE_SERVER
done

# Remote workflows: avoid costly cache generation
for workflow in $REMOTE_WORKFLOWS; do
    echo "Adding remote workflow: $workflow -- $RBBT_WORKFLOW_SERVER"
    rbbt workflow remote add $workflow $RBBT_WORKFLOW_SERVER
done


exit

echo "2.4. Bootstrap system"
#!/bin/bash -x

# APP
# ---

for workflow in $WORKFLOWS; do
    rbbt workflow install $workflow 
done

export RBBT_WORKFLOW_AUTOINSTALL
export RBBT_LOG

for workflow in $BOOTSTRAP_WORKFLOWS; do
    echo "Bootstrapping $workflow on $BOOTSTRAP_CPUS CPUs"
    rbbt workflow cmd $workflow bootstrap $BOOTSTRAP_CPUS
done


EUSER
####################
echo "2. Running user configuration as 'rbbt'"
chown rbbt $user_script;
su -l -c "bash $user_script" rbbt

# CLEAN-UP

RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# DONE
echo
echo "Installation done."

#--------------------------------------------------------

