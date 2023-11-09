# MS-Rewards-Farmer-Docker
A dockerized M$ Rewards Point Farmer

![x](https://badgen.net/github/stars/ltcmdstone/ms-rewards-farmer-docker?icon=github)
![x](https://badgen.net/github/last-commit/ltcmdstone/ms-rewards-farmer-docker?icon=github)
![x](https://badgen.net/github/open-issues/ltcmdstone/ms-rewards-farmer-docker?icon=github)
![x](https://badgen.net/github/open-prs/ltcmdstone/ms-rewards-farmer-docker?icon=github)
![MS-Rewards-Farmer-Docker build and push](https://github.com/LtCMDstone/MS-Rewards-Farmer-Docker/actions/workflows/docker-image.yml/badge.svg?branch=main)

## 📖 Table of Contents
  * [Table of Contents](#---table-of-contents)
  * [Description](#description)
  * [Getting started](#getting-started)
    + [accounts.json](#accountsjson)
    + [Docker run](#docker-run)
    + [Docker compose](#docker-compose)
    + [Unraid](#unraid)
    + [crontab](#crontab)
  * [Notes](#notes)
    + [Volume mapping](#volume-mapping)
    + [ENV variables](#env-variables)
    + [Issues](#issues)

## Description
This is a dockerized version of [**@klept0**](https://github.com/klept0)'s fork of the MS-Rewards-Farmer (intially coded by [**@charlesbel**](https://github.com/charlesbel)) to automatically get points for the MS Rewards program and does all the tasks for you (playing quizzes, searches...)

It runs completly headless in a docker enviroment with google chrome and xvfb as virtual display

## Getting started
Examples how to get the container running.

### accounts.json
   create the accounts.json file with your data

   ```json
   [
     {
       "username": "Your Email",
       "password": "Your Password"
     }
   ]
   ```

   if you want to use multiple accounts/proxy it should look like this
   
   ```json
   [
     {
       "username": "Your Email 1",
       "password": "Your Password 1",
       "proxy": "http://user:pass@host1:port"
     },
     {
       "username": "Your Email 2",
       "password": "Your Password 2",
       "proxy": "http://user:pass@host2:port"
     }
   ]
   ```

### Docker run
```shell
docker run \
  -d \
  --name=ms-reward-farmer \
  -e MSR_VISIBLE=true \
  -v "$PWD"/accounts.json:/app/accounts.json \
  -v "$PWD"/sessions:/app/sessions \
  -v "$PWD"/tmp:/tmp \
  -v "$PWD"/logs:/app/logs \
  --shm-size=3gb ghcr.io/ltcmdstone/ms-rewards-farmer-docker
```
### Docker compose
```yml
services:
  rewards-farmer:
    image: ghcr.io/ltcmdstone/ms-rewards-farmer-docker
    container_name: ms-reward-farmer
    shm_size: 3gb
    volumes:
      - ./accounts.json:/app/accounts.json
      - ./sessions:/app/sessions
      - ./tmp:/app/tmp
      - ./logs:/app/logs
    environment:
      - MSR_VISIBLE=true
    restart: no
```
### Unraid
1. Download the [ms-rewards-farmer.xml](ms-rewards-farmer.xml) file and place it on your unraids flash in the folder ```/flash/config/plugins/dockerMan/templates-user/```

2. In the Docker tab click on ```Add Container``` Button

3. Select the ```MS-Rewards-Farmer``` template

4. fill in your necessary data and hit ```apply```

5. After the container exits with an error, go to your appdata share of the bot and delete the created folder accounts.json and create the accounts.json file instead, like described above [accounts.json](#accounts.json)    

6. restart the container and it should work and farm points for you

### crontab
I recommend to automatically start the container via cron (Unraid: User Scripts Plugin) with a little script to add a random time so the bot doesn't start always at the same time.

```shell
#!/bin/bash

MINWAIT=$((5*60))
MAXWAIT=$((50*60))
SLEEPTIME=$((MINWAIT+RANDOM % (MAXWAIT-MINWAIT)))
echo "sleeping for "$((SLEEPTIME / 60))"m ("$SLEEPTIME"s) ..." 
sleep $SLEEPTIME
echo "starting container"
docker start #container name#

#when using Unraid you can also add the following line for a notification
/usr/local/emhttp/webGui/scripts/notify -b -s "MS-Reward" -i "normal" -m "Container started"
```

```shell
30 5 * * * /bin/bash /path/to/script.sh
```

## Notes
### Volume mapping
In this table all the possible volume mappings are described
|Volume mapping|Description|
|-|-|
|```/app/accounts.json```|(required) JSON file containing account Informations
|```/app/sessions```|chromes session folder (content can be deleted in case of errors)
|```/app/logs```|logs of the bot
|```/tmp```|temporary files like xvfb lock files (content can be deleted in case of errors)

### ENV variables
In this table all the available enviroment variables are listed
|ENV|Bot-Flag|Description|
|-|-|-|
|```MSR_VISIBLE```|-v/--visible|```[true/false]``` disable headless (recommended)|
|```MSR_LANG```|-l/--lang|force a language (ex: ```en```)|
|```MSR_GEO```|-g/--geo|force a geolocation (ex: ```US```)|
|```MSR_PROXY```|-p/--proxy|add a proxy to the whole program, supports http/https/socks4/socks5 (overrides per-account proxy in accounts.json) (ex: ```http://user:pass@host:port```)|
|```MSR_TELEGRAM```|-t/--telegram|add a telegram notification, requires Telegram Bot Token and Chat ID (ex: ```123456789:ABCdefGhIjKlmNoPQRsTUVwxyZ 123456789```)|
|```MSR_DISCORD```|-d/--discord|add a discord notification, requires Discord Webhook URL (ex: ```https://discord.com/api/webhooks/123456789/ABCdefGhIjKlmNoPQRsTUVwxyZ```)|
|```MSR_VERBOSE_NOTIFY```|-vn/--verbosenotifs|```[true/false]``` verbose logs to notification listeners (discord, telegram)|
|```MSR_COMMIT```|check out to previous commit (ex: ```2dd7d53```)|

### Issues
In this table i will try to document possible issues and the solutions
|Issue|possible solution|
|-|-|
|chrome version outdated|wait for new docker image release|
|Tab crash mentioned in log|try to increase the shm-size|
|no such window: target window already closed|try deleteing session and tmp folder|
|...||
