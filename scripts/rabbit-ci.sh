#!/bin/bash
set -v

cat <<EOF | sudo tee /etc/init.d/xvfb > /dev/null
XVFB=/usr/bin/Xvfb
XVFBARGS=":99 -ac -screen 0 1024x768x24"
PIDFILE=/tmp/cucumber_xvfb_99.pid
case "\$1" in
  start)
    echo -n "Starting virtual X frame buffer: Xvfb"
    /sbin/start-stop-daemon --start --quiet --pidfile \$PIDFILE --make-pidfile --background --exec \$XVFB -- \$XVFBARGS
    echo "."
    ;;
  stop)
    echo -n "Stopping virtual X frame buffer: Xvfb"
    /sbin/start-stop-daemon --stop --quiet --pidfile \$PIDFILE
    rm -f \$PIDFILE
    echo "."
    ;;
  restart)
    $0 stop
    $0 start
    ;;
  *)
  exit 1
esac
exit 0
EOF

sudo chown root:root /etc/init.d/xvfb
sudo chmod 0644 /etc/init.d/xvfb

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
