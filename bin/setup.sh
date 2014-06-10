#!/bin/sh

brew install ruby-install
brew install chruby

ruby-install ruby 2.1.1

mkdir -p ~/code && cd ~/code
git clone https://github.com/xfun68/robot.timecards.git
cd robot.timecards

bundle install
crontab -l | { cat; echo "* * * * * /bin/bash -l -c '~/code/robot.timecards/bin/run >> ~/code/robot.timecards/log 2>&1'"; } | crontab -

