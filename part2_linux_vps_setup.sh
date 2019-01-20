#!/bin/bash

# Automatic Commercium Masternodes setup (part 2. VPS masternode setup)
# Dependencies: wget
# (c) Commercium. 2019

version="0.3"
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

# libgomp1 check
GOMPAVAILABLE=`ldconfig -p | grep libgomp1`

if [ -z "$GOMPAVAILABLE" ]; 
then
  echo "[-] libgomp1 not exists at your system."
fi

echo "[!] Commercium daemon depends on libgomp1 !"

# not root/non root mode 
if [ "$EUID" -ne 0 ];
  then 
   echo "You run this installation script at user mode. It's okey! Right now open new terminal window"
   echo "And install run MANNUALLY AS ROOT following command: sudo apt-get libgomp1 -y"
   echo "After that you can continue this install proccess"
   read -p "Manual installation done? Press any key to confirm and continue" 
   echo
  else 
   echo "[+] Trying to install libgomp1 automaticaly"
   apt-get install libgomp1 -y
fi
# end libgomp install


# install commercium daemon
if [ ! -e $HOME/commercium_continuum-v1.0.5-linux.tar.gz ];
then
 printf "Now we will download and install Commercoum deamon to current user home directory: $HOME!\n"
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
echo "[+] extracting files to: $COMMERCIUMCONFIGDIR\n"
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
 echo
 read -n1 -r -p 'Commercium config file already exists.. Press any key to open it in nano editor. Edit it manually or Ctrl-X at next step to exit if config was successfully writen before' key
 nano $COMMERCIUMCONFIG
fi


# Fetch Params
echo
if [ ! -e $HOME/sapling-spend.params ] || [ ! -e $HOME/sprout-proving.key ] || [ ! -e $HOME/sapling-output.params ] || [ ! -e $HOME/sprout-groth16.params ];
then
 $COMMERCIUMDAEMONDIR/fetch-params.sh
fi 

# Start commercium daemon
$COMMERCIUMDAEMONDIR/commerciumd


#
# check daemon running by user confirmation? 
#
read -n1 -r -p 'Lets make sure no errors appear on the screen above and Commercium daemon running... Press any key to confirm or exit with Ctrl-C (solve this issue manually and then restart the script)' key


# Wallet Sync
currentblock="$($COMMERCIUMDAEMONDIR/commercium-cli getblockcount)"
highestblock="$(wget -nv -qO - https://api.commercium.net/api/getblockcount)"


while  [ "$highestblock" != "$currentblock" ]
do
        clear
        highestblock="$(wget -nv -qO - https://api.commercium.net/api/getblockcount)"
        currentblock="$($COMMERCIUMDAEMONDIR/commercium-cli getblockcount)"
        echo "Comparing block heights to ensure server is fully synced";
        echo "Highest: $highestblock";echo "Currently at: $currentblock";
        echo "Checking again in 60 seconds... The install will continue once it's synced.";echo
        echo "Last 6 lines of the log for error checking...";
        echo "===============";
        tail -6 ~/.commercium/debug.log
	echo "===============";
	echo "Network unreachable errors can be normal. Just ensure the current block height is rising over time...";
        sleep 20
done


# Sync done
read -n1 -r -p 'Your blockchain is now synced... Press any key to continue' key

# Finishing touches
echo "Now need to activate masternode."
printf "Following command at LOCAL wallet will activate your mastermode: commercium-cli.exe startmasternode all missing\n\n"

read -n1 -r -p 'Open your local wallet, go to command line shell and activate your masternode Press any key to continue' key
read -n1 -r -p 'Wait a few minutes for your masternode to start... Press any key to continue' key



ans=`$COMMERCIUMDAEMONDIR/commercium-cli masternode debug`

if [[ $ans == *"successfully"* ]]; then
   echo "[+] Masternode successfully started..."
   echo "[+] Congratulations!"
   exit
else
   echo "[-] Masternode NOT started..."
   echo "[-] Something goes wrong. Maybe request help at Commercium discord or ..."   
   printf "[-] Check your masternode status with following command manually and try to fix it: \ncommercium-cli masternode debug\n"
   printf "[-] Correct response from this command is: \"Masternode successfully started\". Then you’re finished.\n" 
fi

exit
