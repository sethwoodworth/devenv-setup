XDG_DATA_HOME=~/.local/share
XDG_CONFIG_DIR=~/.config

PYENV_ROOT=$(XDG_DATA_HOME)/pyenv
PYTHON_VERSION=3.7.2

CODE_DIR=$(HOME)/code

install-pyenv: $(PYENV_ROOT)  ## Install pyenv to XDG_DATA_HOME
$(PYENV_ROOT):
	PYENV_ROOT=$(PYENV_ROOT) bin/pyenv-installer

install-python: $(PYENV_ROOT)/versions/$(PYTHON_VERSION)  ## Install python3
$(PYENV_ROOT)/versions/$(PYTHON_VERSION):
	pyenv install $(PYTHON_VERSION)

build-neovim: $(CODE_DIR)/neovim
$(CODE_DIR)/neovim:
	git clone git@github.com:neovim/neovim.git $(CODE_DIR)/neovim
	cd $(CODE_DIR)/neovim
	make CMAKE_BUILD_TYPE=Release
	sudo make install

.PHONY set-nvim-as-vim
set-nvim-as-vim:
	sudo update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 60
	sudo update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 60
	sudo update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60

.PHONY neovim-deps
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
