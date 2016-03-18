#!/bin/bash
set -v
export GOPATH=$HOME/gopath
export PATH=$HOME/gopath/bin:$PATH
mkdir -p $HOME/gopath/src/github.com/hybridgroup/gobot
rsync -az $HOME/workdir/ $HOME/gopath/src/github.com/hybridgroup/gobot/
cd $HOME/gopath/src/github.com/hybridgroup/gobot
eval "$(curl -sL https://raw.githubusercontent.com/travis-ci/gimme/master/gimme | GIMME_GO_VERSION=1.4 bash)"
sudo add-apt-repository -y ppa:kubuntu-ppa/backports
sudo add-apt-repository -y ppa:zoogie/sdl2-snapshots
sudo apt-get update
sudo apt-get install -y libcv-dev libcvaux-dev libhighgui-dev libopencv-dev libsdl2-dev libsdl2-image-dev libsdl2 libusb-dev xvfb libgtk2.0-0
go get github.com/axw/gocov/gocov
go get github.com/mattn/goveralls
if ! go get github.com/golang/tools/cmd/cover; then go get golang.org/x/tools/cmd/cover; fi

go get -d -v ./...

export DISPLAY=:99.0
sh -e /etc/init.d/xvfb start

./scripts/travis.sh
