hiera-eyaml-secretbox
=====================

NaCl secretbox encryption backend for the
[hiera-eyaml](https://github.com/TomPoulton/hiera-eyaml) module.


Motivation
----------

*censored*


Requirements
------------

You need [RbNaCl](https://github.com/cryptosphere/rbnacl) for the NaCl
operations, which in turn depends on [libsodium](http://www.libsodium.org/):

    $ gem install rbnacl


How to use
----------

### Encrypting and editing encrypted data

Once installed you can create encrypted hiera-eyaml blocks that are encrypted
using Secret Box.

    $ eyaml encrypt -n secretbox -s "A secret string to encrypt"

Use `eyaml --help` for more details or look at the hiera-eyaml docs.

### Configuring hiera

Assuming you have a working `hiera` and `hiera-eyaml` then you need to
configure a path for the `:secretbox_private_key:` and `:secretbox_public_key:`
file locations.
