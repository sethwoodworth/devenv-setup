# TODO: pipsi and favored pipsi packages
# TODO: required apt packages
XDG_DATA_HOME=$(HOME)/.local/share
XDG_CONFIG_DIR=$(HOME)/.config
LOCAL_BIN=$(HOME)/.local/bin

ZSHRCD=$(XDG_CONFIG_DIR)/zsh/zshrc.d

PYENV_ROOT=$(XDG_DATA_HOME)/pyenv

CODE_DIR=$(HOME)/code

PYTHON_VERSION ?= 3.7.2
TERRAFORM_VERSION = 0.11.13

pyenv: $(PYENV_ROOT)  ## Install pyenv to XDG_DATA_HOME
$(PYENV_ROOT):
	PYENV_ROOT=$(PYENV_ROOT) bin/pyenv-installer

install-python: $(PYENV_ROOT)/versions/$(PYTHON_VERSION)  ## Install python3
$(PYENV_ROOT)/versions/$(PYTHON_VERSION):
	PYENV_ROOT=$(PYENV_ROOT) pyenv install $(PYTHON_VERSION)
	PYENV_ROOT=$(PYENV_ROOT) pyenv global $(PYTHON_VERSION)

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

zsh-autosuggestions: $(XDG_DATA_HOME)/zsh-autosuggestions
$(XDG_DATA_HOME)/zsh-autosuggestions:
	git clone https://github.com/zsh-users/zsh-autosuggestions $(XDG_DATA_HOME)/zsh-autosuggestions
	echo 'source $(XDG_DATA_HOME)/zsh-autosuggestions/zsh-autosuggestions.zsh' > $(ZSHRCD)/zsh-autosuggestions.zsh

fzf: $(XDG_DATA_HOME)/fzf  ## Install fzf with keybindings and autocomplete
$(XDG_DATA_HOME)/fzf:
	git clone --depth 1 https://github.com/junegunn/fzf.git $(XDG_DATA_HOME)/fzf
	$(XDG_DATA_HOME)/fzf/install --bin
	ln -s $(XDG_DATA_HOME)/fzf/bin/fzf $(LOCAL_BIN)/fzf
	ln -s $(XDG_DATA_HOME)/fzf/shell/key-bindings.zsh $(ZSHRCD)/fzf-key-bindings.zsh
	ln -s $(XDG_DATA_HOME)/fzf/shell/completion.zsh $(ZSHRCD)/fzf-completion.zsh

scm_breeze: $(XDG_DATA_HOME)/scm_breeze
$(XDG_DATA_HOME)/scm_breeze:
	git clone --depth=1 git://github.com/scmbreeze/scm_breeze.git $(XDG_DATA_HOME)/scm_breeze
	cp ./patches/scm_breeze.sh $(XDG_DATA_HOME)/scm_breeze/scm_breeze.sh
	echo 'source "/home/${USER}/.local/share/scm_breeze/scm_breeze.sh"' > $(ZSHRCD)/scm_breeze.zsh

kitty: $(HOME)/.local/kitty.app/bin/kitty $(HOME)/.local/bin/kitty
$(HOME)/.local/kitty.app/bin/kitty:
	bin/kitty-installer
$(HOME)/.local/bin/kitty:
	ln -s $(HOME)/.local/kitty.app/bin/kitty $(HOME)/.local/bin/kitty


dasht: $(HOME)/.local/share/dasht
$(HOME)/.local/share/dasht:
	git clone git@github.com:sunaku/dasht.git $(HOME)/.local/share/dasht

.DEFAULT_GOAL := help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
