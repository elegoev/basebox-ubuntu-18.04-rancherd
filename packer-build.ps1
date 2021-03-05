# set build environment
../../basebox-ubuntu-18.04/set-build-env.ps1

# run packer for vagrant virtualbox provider
packer build packer-virtualbox.json
