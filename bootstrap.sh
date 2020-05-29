#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

sudo apt install \
  make \
  git\
;

mkdir ~/code;

git clone https://github.com/sethwoodworth/devenv-setup.git ~/code/devenv-setup;

cd ~/code/devenv-setup;
make init;
