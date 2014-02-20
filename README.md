walletserver
============

Chef (and Vagrant) code to deploy and control crypto-currency wallets.

This code is aimed to be part of a larger crypto exchange.  The current target is to:

1. Deploy coin(s) and monitoring system on wallet server.
2. Deploy an ember.js restful interface to coin RPC.
3. Setup business logic and tracking/logging for the restful service.



Init sub-modules first, update, then use Vagrant for testing.  See the sample Vagrantfle
in walletserver cookbook directory.

**Recipes**
`
    chef.add_recipe "walletserver"
    chef.add_recipe "walletserver::install_gperf"
    chef.add_recipe "walletserver::install_openssl"
    chef.add_recipe "walletserver::install_protobuf"
    chef.add_recipe "walletserver::install_bdb"
    chef.add_recipe "walletserver::install_python3"
`


Not all recipes are needed by all coins.  The usual critical ones (for Bitcoin or Litecoin) are:

`
    chef.add_recipe "walletserver"
    chef.add_recipe "walletserver::install_gperf"
    chef.add_recipe "walletserver::install_openssl"
    chef.add_recipe "walletserver::install_bdb"
`

**Why gperf?**

  I've setup a dependency on the Google Performance Tools for all coins.  This is a hard dependency, but can be removed easily by removing the build references.


**Progress**

bitcoind builds

**TODO**

1. Fix leveldb build
2. Move all compile flags to attributes
3. Setup coin configs
4. Setup monit for coins.


Donations:


BTC: 1KogumaB8gTZBNM5NFCyG1cMx9k2hb7NNA
DVC: 12VfaJToeCxRAU36bWfehBBooLeBaKx4tP 
LTC: LT56PMhz16szVk3RFGB9ASfuYtQJuSRS8p
TES: 5pVjo5M1rZRqGatTXefT6dVTKP1zo66nBS


