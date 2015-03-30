#!/bin/bash

gem uninstall hiera-eyaml-secretbox
rake build
gem install pkg/hiera-eyaml-secretbox
eyaml -v
