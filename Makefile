# TODO: pipsi and favored pipsi packages
# TODO: required apt packages
XDG_DATA_HOME=~/.local/share
XDG_CONFIG_DIR=~/.config

PYENV_ROOT=$(XDG_DATA_HOME)/pyenv

CODE_DIR=$(HOME)/code

PYTHON_VERSION=3.7.2
TERRAFORM_VERSION=0.11.13

install-pyenv: $(PYENV_ROOT)  ## Install pyenv to XDG_DATA_HOME
$(PYENV_ROOT):
	PYENV_ROOT=$(PYENV_ROOT) bin/pyenv-installer

install-python: $(PYENV_ROOT)/versions/$(PYTHON_VERSION)  ## Install python3
$(PYENV_ROOT)/versions/$(PYTHON_VERSION):
	PYENV_ROOT=$(PYENV_ROOT) pyenv install $(PYTHON_VERSION)

.PHONY: neovim-deps
neovim-deps:
	sudo apt install \
	  ninja-build \
	  gettext \
	  libtool \
	  libtool-bin \
	  autoconf \
	  automake \
	  cmake \
	  g++ \
	  pkg-config \
	  unzip

clone-neovim: $(CODE_DIR)/neovim
$(CODE_DIR)/neovim:
	git clone git@github.com:neovim/neovim.git $(CODE_DIR)/neovim
	cd $(CODE_DIR)/neovim

build-neovim: $(CODE_DIR)/neovim /usr/local/bin/nvim
/usr/local/bin/nvim:
	cd $(CODE_DIR)/neovim
	make CMAKE_BUILD_TYPE=Release
	sudo make install

.PHONY: set-nvim-as-vim
set-nvim-as-vim:
	sudo update-alternatives --install /usr/bin/vi vi /usr/local/bin/nvim 60
	sudo update-alternatives --install /usr/bin/vim vim /usr/local/bin/nvim 60
	sudo update-alternatives --install /usr/bin/editor editor /usr/local/bin/nvim 60

neovim: neovim-deps clone-neovim build-neovim set-nvim-as-vim   ## Clone, build, install, and set update-alternatives for neovim

terraform: ~/.local/bin/terraform  ## Install Terraform to ~/.local/bin
~/.local/bin/terraform:
	wget https://releases.hashicorp.com/terraform/$(TERRAFORM_VERSION)/terraform_$(TERRAFORM_VERSION)_linux_amd64.zip
	unp terraform_$(TERRAFORM_VERSION)_linux_amd64.zip
	rm terraform_$(TERRAFORM_VERSION)_linux_amd64.zip
	mv terraform ~/.local/bin/

packer: /usr/bin/packer  ## Install packer via apt
/usr/bin/packer:
	sudo apt install packer



.DEFAULT_GOAL := help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
