# walletserver cookbooks

[![Build Status](https://travis-ci.org/azilber/walletserver.png?branch=master)](https://travis-ci.org/azilber/walletserver)


***UPDATES***

1. Openssl updated to 1.01g (Heartbleed)
2. Bitcoin updated to 0.9.1
3. Devcoin added
4. Roles will only by partially updated in the future.

walletserver
============

Chef (and Vagrant) code to deploy and control crypto-currency wallets.

This code is aimed to be part of a larger crypto exchange.  The current target is to:

1. Deploy coin(s) and monitoring system on wallet server.
2. Deploy backbone.js restful interface to coin RPC.
3. Setup business logic and tracking/logging for the restful service.



Init sub-modules first, update, then use Vagrant for testing.  See the sample Vagrantfle
in walletserver cookbook directory for vbox source and example.

Recipes
-----------
```
     "walletserver"
     "walletserver::install_gperf"
     "walletserver::install_openssl"
     "walletserver::install_leveldb"
     "walletserver::install_protobuf"
     "walletserver::install_bdb"
     "walletserver::install_python3"
     "walletserver::install_boost"
     "coins::setup_bitcoin"
```


Not all recipes are needed by all coins.  The usual critical ones (for Bitcoin or Litecoin) are:

```
     "walletserver"
     "walletserver::install_gperf"
     "walletserver::install_openssl"
     "walletserver::install_leveldb"
     "walletserver::install_boost"
     "walletserver::install_bdb"
```

Why gperf?
-----------

  I've setup a dependency on the Google Performance Tools for all coins.  This is a hard dependency, but can be removed easily by removing the build references.


Done
-----------

1. bitcoind
2. devcoind
2. Restore wallet.dat from S3 bucket.


Current Progress
-----------

Generic builds

TODO
-----------

1. Move all compile flags to attributes - Mostly done.
2. Setup generic coin configs. - Partly done
3. Save wallet.dat to S3. - done
4. Clustring via pub/sub.
5. Auto-share addnode logic via cluster.
6. Actual Ubuntu support
7. Documentation


Controlling Coin Daemons
-----------

Daemons are monitored and controlled via monit:

1. 'monit status' - shows status of daemons
2. 'monit stop bitcoind' - stops the bitcoind daemon
3. 'monit start bitcoind' - start the bitcoind daemon


Getting Started
-----------
0. Grab Oracle VirtualBox and this image http://www.mediafire.com/download/8fcbxywxngau25w/centos64_x64_chef_11.8.2.box  (mostly tested on Centos 6.x)
1. It can take a very long time to build all the required libraries.  I've implemented an archive and restore system via S3. Setup your AWS S3 credential's in the walletserver's attributes,
and bucket name.
2. Use the 'archive' role.  Allow the boot to properly finish.  You will have an archive of all the libs; 'vagrant up && yes | vagrant destroy'
3. Use any of the other roles afterwards in future boots that contain the 'walletserver::restore_root' recipe.; then vagrant up

```
[root@vagrant ~]# monit status
The Monit daemon 5.1.1 uptime: 34m 

Process 'devcoind'
  status                            running
  monitoring status                 monitored
  pid                               20400
  parent pid                        1
  uptime                            25m 
  children                          0
  memory kilobytes                  94388
  memory kilobytes total            94388
  memory percent                    4.9%
  memory percent total              4.9%
  cpu percent                       2.2%
  cpu percent total                 2.2%
  port response time                0.000s to 127.0.0.1:53333 [DEFAULT via TCP]
  data collected                    Sat Apr 12 00:44:40 2014

Process 'bitcoind'
  status                            running
  monitoring status                 monitored
  pid                               19949
  parent pid                        1
  uptime                            32m 
  children                          0
  memory kilobytes                  89744
  memory kilobytes total            89744
  memory percent                    4.6%
  memory percent total              4.6%
  cpu percent                       3.5%
  cpu percent total                 3.5%
  port response time                0.000s to 127.0.0.1:8332 [DEFAULT via TCP]
  data collected                    Sat Apr 12 00:44:40 2014

System 'vagrant.localdomain'
  status                            running
  monitoring status                 monitored
  load average                      [0.04] [0.05] [0.11]
  cpu                               3.4%us 1.2%sy 1.2%wa
  memory usage                      341544 kB [17.7%]
  data collected                    Sat Apr 12 00:44:40 2014
```


#####Donations:#####


* BTC: 1KogumaB8gTZBNM5NFCyG1cMx9k2hb7NNA
* DVC: 12VfaJToeCxRAU36bWfehBBooLeBaKx4tP 
* LTC: LT56PMhz16szVk3RFGB9ASfuYtQJuSRS8p
* TES: 5pVjo5M1rZRqGatTXefT6dVTKP1zo66nBS


