# Packer - build an Ubuntu Xenial64 Vagrant box

A packer project that builds an Ubuntu Xenial64 Vagrant box for VirtualBox provider. The box will be uploaded to Vagrant Cloud and the uploaded box tested with KitchenCI.

## Prerequisites

Building the Vagrant box and uploading to Vagrant Cloud with Packer:

* [Install](https://www.packer.io/intro/getting-started/install.html) Packer
* [Install](https://www.virtualbox.org/wiki/Downloads) VirtualBox

Testing the uploaded box with KitchenCI - will run only on MAC/Linux:

* Ruby version 2.5.1 - it is recommended to use a Ruby versions manager like `rbenv`. To set up `rbenv` on MAC:
  * Install rbenv - run `brew install rbenv`
  * Initialize rbenv - add to `~/.bash_profile` line `eval "$(rbenv init -)"`
  * Run `source ~/.bash_profile`
  * Install ruby 2.5.1 with rbenv - run `rbenv install 2.5.1` , check `rbenv versions`
  * Set local ruby version for the project to 2.5.1 - run `rbenv local 2.5.1` , check `rbenv local`
* Installed Ruby bundler - `gem install bundler`. If using `rbenv` run also `rbenv rehash`.
* Installed `jq` package

## Setup

The packer template relies on several environment variables:

* `ISO_URL` - the url of the .iso image of the OS
* `ISO_SHA` - the SHA256 check sum for the .iso image
* `VC_BOX_NAME` - the tag of the Vagrant Cloud box to which the artefact will be uploaded - `myVCuser\myBox`.
* `VC_BOX_VER` - the version of the Vagrant Cloud box which will be created. If the version exists and it has a VirtualBox provider the upload will **fail**.
* `BOX_OS_VER` - the exact version of the Ubuntu OS e.g. "16.04.6". Used for creating the VC cloud box description and as a test value.
* `VAGRANT_CLOUD_TOKEN` -  the user token for Vagrant Cloud.

The project includes a bash script which can be used to set the variables and run packer. The `VAGRANT_CLOUD_TOKEN` still needs to be set manually.

Script usage:

`./run.sh <ubuntu_version> <vc_box_name> [vc_box_version]` - if the `vc_box_version` is not provided the `ubuntu_version` will be used for the VC box as well.

When run with the script packer will execute all the post-processors - for more details read the next section.

## Running Packer

1. Running the full project - `./run.sh <ubuntu_version> <vc_box_name> [vc_box_version]` or set the variables and run `packer build template.json`

This will:

* Create the Vagrant box
* Upload the box to Vagrant Cloud. The box will be uploaded as the version provided with `VC_BOX_VER` with `.pre` appended to it.
* Run a local script to test the uploaded box with KitchenCI - only if run on MAC/Linux. If the test passes the box version will be renamed - the `.pre` will be removed.

2. Running the project but excluding some packer post-processors - `packer build -except <pp1>,<pp2> template.json`

The packer project uses the following post-processors:

* `vagrant` - creates the Vagrant box
* `vagrant-cloud` - uploads the created box to Vagrant Cloud
* `shell-local` - downloads the uploaded box, tests it and if test is passed renames the version.

Note:
The post processors run in the sequence above. If you disable one you need to disable all of the following as well, otherwise they will fail and packer will exit with error.
This way it is not possible to use the script from the `shell-local` post-processor to test the box before uploading it to Vagrant Cloud as part of the packer build.

Example: to build the vagrant box, but not upload it (and so not test the box from Vagrant Cloud)

`packer build -except vagrant-cloud,shell-local template.json`
