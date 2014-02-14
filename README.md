walletserver
============

Chef (and Vagrant) code to deploy and control crypto-currency wallets.

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

*Why gperf?*

  I've setup a dependency on the Google Performance Tools for all coins.  This is a hard dependency, but can be removed easily by removing the build references.
