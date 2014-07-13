# LEMP

A nginx, php-fpm and percona mysql with supervisor based on Centos 6.5 docker image 

## Installation

```
$ git clone https://github.com/sdbruder/lemp.git
$ cd lemp
$ docker build -t lemp .
```

## Usage

To spawn a new instance of your nginx / php-fpm stack:

```bash
$ docker run -d -p 23:22 -p 80:80 -p 3306:3306 lemp
```

You'll see an ID output like:
```
6174e0e95d7e21dd8bc69c9eb670d9a3407fca1bdd81573b230de1fd3d1ab79d
```

Use this ID to check the port it's on:
```bash
$ docker port d404cc2fa27b 80 # Make sure to change the ID to yours!
```

If you are using boot2docker in a non-linux environment, you can get the external ip address of the boot2docker VM with:
```bash
$ boot2docker ip

The VM's Host only interface IP address is: 192.168.59.103

```
So in that example you can access your nginx with http://192.168.59.103/

This image doesnt persist mysql data but are exposing mysql port, too, so in the same ip address used to get web going you can connect a mysql client and import your data using root with no password as auth config.

