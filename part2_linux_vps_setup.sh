#!/bin/sh

# Automatic Commercium Masternodes setup (part 2. VPS masternode setup)
# Dependencies: wget
# (c) Commercium. 2019

version="0.1beta"
COMMERCIUMCONFIGDIR=~/.commercium
COMMERCIUMDAEMONDIR=~/commercium_continuum-v1.0.5-linux
COMMERCIUMCONFIG=$COMMERCIUMCONFIGDIR/commercium.conf
COMMERCIUMMASTERNODECONFIG=$COMMERCIUMCONFIGDIR/cmasternode.conf


clear
printf "Before you begin. Follow instuction about how to setup masternodes at your local wallet (part 1). You can find this documentation here:\n\n https://github.com/CommerciumBlockchain/masternode-scripts\n\n"
printf "Confirm that you are alredy have NODEKEY to setup your VPS masternode.\n"

while true; do
    read -p "Do you wish to install Commercium daemon now? " yn
    case $yn in
        [Yy]* ) echo ""; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done


if [ ! -e $HOME/commercium_continuum-v1.0.5-linux.tar.gz ];
then
 printf "Now we will download and install Commercoum deamon to current user home directory: $HOME!"
 echo
 cd $HOME
 wget https://github.com/CommerciumBlockchain/CommerciumContinuum/releases/download/v1.0.5/commercium_continuum-v1.0.5-linux.tar.gz
fi

if [ ! -e $HOME/commercium_continuum-v1.0.5-linux.tar.gz ];
then
  echo "Error downloading commercium wallet linux archive."
  exit
fi

echo "[+] Commercium successfully downloaded and stored at user home: $HOME "


# extract 
echo "[+] extracting files to: $COMMERCIUMCONFIGDIR"
tar zxvf commercium_continuum-v1.0.5-linux.tar.gz


# Config & dir
if [ ! -d "$COMMERCIUMCONFIGDIR" ]; then
  mkdir $COMMERCIUMCONFIGDIR
fi

echo "[+] writing commercium.conf config file: $COMMERCIUMCONFIG"

if [ ! -e $COMMERCIUMCONFIG ];
then
 USERNAMERAND=`head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo ''`
 PASSWORDRAND=`head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo ''`
 read -p "Now please enter/copy&paste your NODEKEY from Part 1 setup instructions: " NODEKEY

cat <<EOF > $COMMERCIUMCONFIG
txindex=1
daemon=1
rpcuser=$USERNAMERAND
rpcpassword=$PASSWORDRAND
masternode=1
masternodeprivkey=$NODEKEY
EOF

else
 read -n1 -r -p "Commercium config file already exists: $COMMERCIUMCONFIG... Press any key to open it in nano for editing. Нou can edit it manually or Ctrl-X at next step to exit if no action is required and config was successfully writen before";echo
 nano $COMMERCIUMCONFIG
fi


# Fetch Params
echo

while true; do
    read -p "Do you wish to fetch z-params (if you not sure press y)? " yn
    case $yn in
        [Yy]* ) $COMMERCIUMDAEMONDIR/fetch-params.sh; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

# Start commercium daemon
$COMMERCIUMDAEMONDIR/commerciumd


#
# check daemon running? 
#

read -n1 -r -p "Let's make sure no errors appear and Commercium daemon running... Press any key to continue";echo


#
currentblock="$($COMMERCIUMDAEMONDIR/commercium-cli getblockcount)"

read -n1 -r -p "Please, check https://explorer.commercium.net/ block number and make sure that its the same or higher then this number from your Commercium daemon: $currentblock Press any key to continue";echo
echo
read -n1 -r -p "If it's ok then your blockchain is now synced... Press any key to continue or wait for sync";echo

###Finishing touches
printf "Following command at local wallet will activate your mastermode: commercium-cli.exe startmasternode all missing"
read -n1 -r -p "Now open your local wallet, go to command line shell and activate your masternode Press any key to continue";echo
read -n1 -r -p "Wait a few minutes for your masternode to start... Press any key to continue";echo



ans=`$COMMERCIUMDAEMONDIR/commercium-cli masternode debug`

if [ X"$ans" == X"successfully" ]; then
   printf "[+] Masternode successfully started..."
else
   printf "[-] Masternode NOT started..."	
   printf "[-] Check your masternode status with following command: commercium-cli masternode debug"
   printf ""
fi

read -n1 -r -p "If the response is: “Masternode successfully started“, you’re finished.... Press any key to finish";echo
