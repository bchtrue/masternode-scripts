# Инструкция по установке мастерноды Commercium 



В этой инструкции будет описано как установить локальный кошелек Commercium на Windows/Linux/MacOs (для активации мастерноды) и Linux VPS как хостинг для мастерноды.  


Вы можете установить всю мастерноду на свой домашний компьютер, но для того он должен работать 24 часа в сутки и иметь выделенный IP адрес. Когда Ваша мастернода работает, Ваши монеты в безопасности, потому что они хроняться локально, не на ВПС (где работает сама мастернода)

## Требования: 



- 100000 CMM + 0.001 CMM для оплаты транзакционных комиссий

- VPS с минимум 1024 RAM, 1 CPU, >20 GB HDD или больше

- Commercium локальный кошелек установленный на Windows/Linux/MacOs PC и VPS

- VPS: лучше последняя ubunty (18.04). Но может работать на 16.04 просто установите: `apt-get install libgomp1`

- `putty` remote shell client (putty.org)





# PART 1: Local machine setup



### Fresh wallet installation: 



#### 1. Install latest Commercium wallet at your local machine from this link: 



https://github.com/CommerciumBlockchain/CommerciumContinuum/releases 



Follow this video instructions for help:



https://youtu.be/AQMogS3Enjs (Windows)



https://youtu.be/xuLRBuvaSgU (MacOS)





##### Upgrade old wallet



If you are already have old Commercium wallet then backup your data and export your private keys. You will import them later to new wallet:





Buckup `~/.commercium` - directory for MacOs/Linux



Windows users (use command shell `cmd.exe`). 



Press `Win+r` -> write `cmd` -> press Enter -> copy&paste this commands into the shell: 



```

move %APPDATA%/ZcashParams  %APPDATA%/ZcashParams.backup

move %APPDATA%/Commercium  %APPDATA%/Commercium.backup

