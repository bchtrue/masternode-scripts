# Commercium Masternode Setup

A step by step guide howto setup your Commercium Masternode on Windows/Linux/MacOS local wallet & Linux VPS as remote MN.


You also can run your masternode at your own computer, but it must be operational 24/7 and have a dedicated IP address. When you run your masternode your funds are safe and stored at your local wallet, not at the VPS (linux machine most cases).


## Requirements: 

- 100000 CMM + 0.001 CMM to pay transaction fees
- VPS with at least 1024 RAM, 1 CPU, >20 GB HDD or more
- Commercium wallet at local Windows/Linux/MacOs PC and VPS
- VPS: better to use latest ubunty (18.04). If you run 16.04 just install: `apt-get install libgomp1`
- `putty` remote shell client (putty.org)

## Masternode info

Masternode reward is completely random. One masternode out of 
total MN numbers are picked at random. There is no seniority, no weighting, just 
random. So each minute you have a one in (total MN) chance of getting the 
reward.

- 1440 * 8 = 11,520 CMM mined per day 
- 1440 * 5.0 = 7,200 goes to miners 
- 1440 * 2.4 = **3,456** goes to all masternodes 
- 1440 * 0.6 = 864 goes to founders fund


# PART 1: Local machine setup

### Fresh wallet installation: 

#### 1. Install latest Commercium wallet at your local machine from this link: 

https://github.com/CommerciumBlockchain/CommerciumContinuum/releases 

Follow this video instructions for help:

https://youtu.be/AQMogS3Enjs (Windows)

https://youtu.be/xuLRBuvaSgU (MacOS)


##### Upgrade old wallet

If you are already have old Commercium wallet then backup your data and export your private keys. You will import them later to new wallet:

_Video instruction about how to migrate to new Commercium wallet:_ `https://youtu.be/xuLRBuvaSgU?t=166` 

Buckup `~/.commercium` - directory for MacOs/Linux

Windows users (use command shell `cmd.exe`). 

Press `Win+r` -> write `cmd` -> press Enter -> copy&paste this commands into the shell: 

```
move %APPDATA%/ZcashParams  %APPDATA%/ZcashParams.backup
move %APPDATA%/Commercium  %APPDATA%/Commercium.backup
```


#### 2. We must edit our local wallet configuration file `commercium.conf`.You can find `commercium.conf` here:

- Linux: `~/.commercium` directory
- Windows: `%appdata%/Commercium` folder
- MAC: `~/Library/Application Support/Commercium`

Open your shell. _How to do this described at previous step under "Upgrade old wallet"._ Enter this commands at Windows shell:

```
cd %appdata%/Commercium
notepad commercium.conf 
or better alternative:
open `commercium.conf` for editing with other editor. 
I suggest to edit it with external editor like Notepad++,
because the default notepad on Windows 7
did not recognize and break unix wrapping at this file.
```

Append this new line to the end of the file (`commercium.conf`):

`txindex=1`

Save & Close editor.

#### 3. Exit windows wallet. Next we will do a full blockchain rescan to create transaction index.

Run this command at Windows shell: `commerciumd.exe -reindex`

Linux shell: `./commercium -reindex`

**OR ALTERNATIVE:** 

Windows:

```
del %APPDATA%\Commercium\peers.dat
del %APPDATA%\Commercium\budget.dat
del %APPDATA%\Commercium\mn*.dat
del %APPDATA%\Commercium\sporks /Q
del %APPDATA%\Commercium\chainstate /Q
del %APPDATA%\Commercium\blocks /Q
del %APPDATA%\Commercium\blocks\index /Q
del %APPDATA%\Commercium\database /Q
```

Linux:

```
rm -rf ~/.commercium/blocks
rm -rf ~/.commercium/database
rm -rf ~/.commercium/chainstate
rm -rf ~/.commercium/sporks
rm ~/.commercium/mn*.dat
rm ~/.commercium/budget.dat
rm ~/.commercium/peers.dat
```

MacOSX:

```
rm -rf Library/Application\ Support/Commercium/blocks
rm -rf Library/Application\ Support/Commercium/database
rm -rf Library/Application\ Support/Commercium/chainstate
rm -rf Library/Application\ Support/Commercium/sporks
rm Library/Application\ Support/Commercium/mn*.dat
rm Library/Application\ Support/Commercium/budget.dat
rm Library/Application\ Support/Commercium/peers.dat
```

Run new wallet release and wait until all block will be resynced. At QT Windows wallet check the tap "commerciumd" and wait until "Downloading blocks" will be 100% done. If you run `-reindex` at command line shell then close your `cmd` shell and run QT wallet.

#### 4. At this step we will send your CMM masternode coins to some new collateral address (you'll receive masternode reward to this address).

Create new `t-Addr`. You can do this at "Receive" tab. Then send coins to this address from "send" tab. 

Transfer _exactly_ 100000 CMM to this address. 

**WARNING:** save new private key for this new address and make `wallet.dat` backup now!


#### 5. Then need to edit masternode config file to setup masternode:

Open `masternode.conf` for editing as you do it before with other config file.

```
Format: alias IP:port masternodeprivkey(NODEKEY) collateral_output_txid(OUTPUTTXID) collateral_output_index(OUTPUTINDEX) 
# Example: mn1 127.0.0.2:51474 93HaYBVUCYjEMeeH1Y4sBGLALQZE1Yc1K64xiqgX37tGBDQL8Xg 2bcd3c84c84f87eaa86e4e56834c92927a07f9e18718810b92e0d0324456a67c 0
```

As you see above to setup masternode we must have the following data:

* **ALIAS** - masternode alias
* **IP** - VPS IP
* **PORT** - always the same 2019
* **NODEKEY** - masternode private key (looks like generated numbers and charts)
* **OUTPUTTXID** - collateral output txid
* **OUTPUTINDEX** - collateral output index (is usually `0`)



#### 6. Bellow is where all this requested information comes from:


##### 6.1 Generating **NODEKEY** masternode private key. Run this at _local_ wallet where you store your coins:

`commercium-cli.exe masternode genkey `

Output of this command is your Masternode Private Key (**NODEKEY**)

##### 6.2 **OUTPUTTXID** and **OUTPUTINDEX**

`commercium-cli.exe masternode outputs`

show "txhash" and "outputidx". txhash is your **OUTPUTTXID** / outputid is **OUTPUTINDEX**

##### 6.3 Now you are ready to add all this information to `masternode.conf`.

Format: `ALIAS IP:2019 NODEKEY OUTPUTTXID OUTPUTINDEX` (separated with spaces, only IP and PORT separated with `:`) 

##### 6.4 Save your `masternode.conf` changes.







# PART 2 (VPS Setup)

All local wallet configuration done. Now, we will setup VPS commercium wallet.

### Masternode setup process (VPS): 

Connect with `Putty` to your VPS. Just enter IP address of your VPS at the Putty windows and login with your VPS username/password.

If you need video instruction check this video: https://youtu.be/vVVhtQ5Wd3g

![Putty Connect](https://i1.wp.com/www.codingepiphany.com/wp-content/uploads/2014/04/putty_initial_connection.png?resize=466%2C446)

After connection enter your username and password then you will see linux shell.

#### _0. (not neccessory step). Run as regular user not root. 

For securety purposes you can run your masternode as regular linux user, not `root`. If you want this then create new user `adduser cmmuser` (run as root) and then connect to your VPS with Putty again and login with this new user login and password._

#### Automatic VPS setup script:

If you do not want to follow **part 2. Vps install mannualy** you can use our automatic VPS setup script `part2_linux_vps_setup.sh`:

```
wget https://raw.githubusercontent.com/CommerciumBlockchain/masternode-scripts/master/part2_linux_vps_setup.sh
chmod +x part2_linux_vps_setup.sh
./part2_linux_vps_setup.sh
```

###### Troubles and notes about this script 

- You can use it to install your commercium daemon as user (not root) for better securety. 
- Because of this you must install dependences manually as root with following command: `sudo apt-get install wget nano libgomp1 -y` or check that your system has this packages.
- If you choose this automatic method, then skip 1-3 steps and go to __step 4__ below to activate your masternode and you are done!



#### 1. Enter this commands at linux shell: 

`cd ~` _(to be sure that you are at user home directory)_

It will download archive with commercium to current directory.

`wget https://github.com/CommerciumBlockchain/CommerciumContinuum/releases/download/v1.0.5/commercium_continuum-v1.0.5-linux.tar.gz`

_Hint: You can check available files at the current directory with `ls` command to check that `commercium_continuum-v1.0.5-linux.tar.gz` is here! _

#### 2. Extract files with following commands: 

`tar -xzvf commercium_continuum-v1.0.5-linux.tar.gz`

_Note: It will extract all commercium files to `commercium_continuum-v1.0.5-linux` directory_

#### 3. Make directiry for configuration files and database:

`mkdir .commercium`

And then we will create `commercium.conf`:

`echo -e "txindex=1\ndaemon=1\nrpcuser=CHANGEthisPASSWORD]\nrpcpassword=CHANGEthisPASSWORD\nmasternode=1\nmasternodeprivkey=NODEKEY" > .commercium/commercium.conf`

or create new config file at `.commercium` directory with the following command:

`nano ~/.commercium/commercium.conf` 

add following:

```
txindex=1
daemon=1
rpcuser=[RANDOM USERNAME]
rpcpassword=[[RANDOM PASSWORD]
masternode=1
masternodeprivkey=[NODEKEY]
```

Hint: to paste text at `nano` you can use `ctrl+shift+v`, or `middle mouse click`, or `shift+insert`

`NODEKEY` - is the key from previous part (6.1)

`PASSWORD` - random password. Use at least 10 charts secure password.

`[]` -- must be also removed.


**NOW YOU MASTERNODE IS READY TO START!**

#### 4. Masternode Activation

on local wallet windows `cmd` shell: `commercium-cli.exe startmasternode all missing` alternative command: `commercium-cli.exe startalias MASTERNODEALIAS`


Success start example output:
```
{
  "overall": "Successfully started 1 masternodes, failed to start 0, total 1",
  "detail": [
    {
      "alias": "mn1",
      "result": "success",
      "error": ""
    }
  ]
}
```

on vps `./commercium-cli masternode debug` must display "Masternode successfully started." if not, wait 20 minutes and start the masternode again using the command above.

To activate a masternode the local wallet and masternode must have the masternode list synced
`./commercium-cli mnsync status` to check it.

There are 2 sync; one is blockchain and one is masternode. In some cases need to wait for full sync ~30 mins.

If you have troubles with syncing (it stop syncking) then it's possible to resync: Part 1) 3.

#### 5. How to add commercium daemon to start automatically after VPS reboot

Create new file `nano cmmstartup.sh`
with following text:

```
#!/bin/sh
cd ~/commercium_continuum-v1.0.5-linux
./commerciumd
```
then 
`chmod +x cmmstartup.sh`

`crontab -e`

add this line to the bottom:
`@reboot bash ~/cmmstartup.sh`

To test it just reboot your vps.

P.S. Secure your vps: 
https://www.eurovps.com/blog/20-ways-to-secure-linux-vps/

#### Masternode reward.

All rewards must be shielded by sending to a transparent Z address starting with C

