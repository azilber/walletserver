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
2. Restore wallet.dat from S3 bucket.

Current Progress
-----------

Generic builds

TODO
-----------

1. Move all compile flags to attributes
2. Setup generic coin configs
3. Save wallet.dat to S3.
4. Clustring via pub/sub.
5. Auto-share addnode logic via cluster.


Controlling Coin Daemons
-----------

Daemons are monitored and controlled via monit:

1. 'monit status' - shows status of daemons
2. 'monit stop bitcoind' - stops the bitcoind daemon
3. 'monit start bitcoind' - start the bitcoind daemon


#####Donations:#####


* BTC: 1KogumaB8gTZBNM5NFCyG1cMx9k2hb7NNA
* DVC: 12VfaJToeCxRAU36bWfehBBooLeBaKx4tP 
* LTC: LT56PMhz16szVk3RFGB9ASfuYtQJuSRS8p
* TES: 5pVjo5M1rZRqGatTXefT6dVTKP1zo66nBS


