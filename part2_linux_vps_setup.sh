#!/bin/sh

# Automatic Commercium Masternodes setup (part 2. VPS masternode setup)
# Dependencies: 
# (c) Commercium. 2019

version="0.1beta"
COMMERCIUMCONFIGDIR=~/.commercium
COMMERCIUMDAEMONDIR=~/commercium_continuum-v1.0.5-linux
COMMERCIUMCONFIG=$COMMERCIUMCONFIGDIR/commercium.conf
COMMERCIUMMASTERNODECONFIG=$COMMERCIUMCONFIGDIR/cmasternode.conf


clear
read -n1 -r -p "Before you begin, follow PART 1 instuction about how to setup masternodes: https://github.com/CommerciumBlockchain/CommerciumMasternodesSetup/Readme.md Press any key to continue... or CTRL-C to exit";echo
read -n1 -r -p "Confirm that you are alredy have NODEKEY to setup VPS masternode. And let's begin setting up Commercium MN at the VPS. Press any key to continue...";echo
read -n1 -r -p "Now we will download and install Commercoum deamon to current user home! Press any key to continue...";echo

while true; do
    read -p "Do you wish to install this program?" yn
    case $yn in
        [Yy]* ) make install; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

#sudo apt-get -y install 
echo "downloading files to $HOME . . . "
cd $HOME
wget https://github.com/CommerciumBlockchain/CommerciumContinuum/releases/download/v1.0.5/commercium_continuum-v1.0.5-linux.tar.gz

if [ ! -e $HOME/commercium_continuum-v1.0.5-linux.tar.gz ];
then
  echo "Error downloading commercium wallet linux archive."
  exit
fi

# extract 
echo "extracting files . . . "
tar zxvf commercium_continuum-v1.0.5-linux.tar.gz


# Config 
if [ ! -d "$COMMERCIUMCONFIGDIR" ]; then
  mkdir $COMMERCIUMCONFIGDIR
fi

if [ ! -e $COMMERCIUMCONFIG ];
then

USERNAMERAND=`pwgen 13 1`
PASSWORDRAND=`pwgen 13 1`

read -p "Now please enter or better Paste you NODEKEY from Part 1 setup instructions: " NODEKEY

cat <<EOF > $COMMERCIUMCONFIG
txindex=1
daemon=1
rpcuser=$USERNAMERAND
rpcpassword=$PASSWORDRAND
masternode=1
masternodeprivkey=$NODEKEY
EOF

else
	nano $COMMERCIUMCONFIG
fi


# Fetch Params
echo

while true; do
    read -p "Do you wish to fetch z-params (if you not sure press y)?" yn
    case $yn in
        [Yy]* ) $COMMERCIUMDAEMONDIR/fetch-params.sh; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done


read -n1 -r -p "Let's make sure no errors appear and that Commercium daemon running... Press any key to continue";echo


#Set Vars
currentblock="$($COMMERCIUMDAEMONDIR/commercium-cli getblockcount)"

read -n1 -r -p "Please, check https://explorer.commercium.net/ block number and make sure that its the same or high then this: $currentblock Press any key to continue";echo
echo
read -n1 -r -p "Your blockchain is now synced... Press any key to continue";echo

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
