# TODO: required apt packages
XDG_DATA_HOME=$(HOME)/.local/share
XDG_CONFIG_DIR=$(HOME)/.config
LOCAL_BIN=$(HOME)/.local/bin

ZSHRCD=$(XDG_CONFIG_DIR)/zsh/zshrc.d

PYENV_ROOT=$(XDG_DATA_HOME)/pyenv
PIPSI_VENVS=$(HOME)/.local/venvs

CODE_DIR=$(HOME)/code

PYTHON_VERSION ?= 3.7.3
TERRAFORM_VERSION = 0.11.14
NODEJS_VERSION ?= 10.15.3
# Rust
CARGO_HOME=$(XDG_DATA_HOME)/cargo
RUSTUP_HOME=$(XDG_DATA_HOME)/rustup

pyenv: $(ZSHRCD)/pyenv.zsh  ## Install pyenv to XDG_DATA_HOME
$(ZSHRCD)/pyenv.zsh:
	PYENV_ROOT=$(PYENV_ROOT) bin/pyenv-installer
	ln -s $(PYENV_ROOT)/libexec/pyenv $(LOCAL_BIN)/pyenv
	echo 'eval "$$(pyenv init -)"' > $(ZSHRCD)/pyenv.zsh
	echo 'eval "$$(pyenv virtualenv-init -)"' >> $(ZSHRCD)/pyenv.zsh

install-python: $(PYENV_ROOT)/versions/$(PYTHON_VERSION) $(ZSHRC)/pip-completion.zsh ## Install python3
$(PYENV_ROOT)/versions/$(PYTHON_VERSION):
	sudo apt install -y make build-essential libssl-dev zlib1g-dev libbz2-dev \
libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
xz-utils tk-dev libffi-dev liblzma-dev python-openssl git
	PYENV_ROOT=$(PYENV_ROOT) pyenv install $(PYTHON_VERSION)
	PYENV_ROOT=$(PYENV_ROOT) pyenv global $(PYTHON_VERSION)

$(ZSHRC)/pip-completion.zsh:
	cp ./completion/pip-completion.zsh $(ZSHRCD)/pip-completion.zsh

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
	git clone https://github.com/neovim/neovim.git $(CODE_DIR)/neovim
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

nvim-venv: $(HOME)/.local/venvs/nvim/bin/python3 install-python
$(HOME)/.local/venvs/nvim/bin/python3:
	mkdir -p $(HOME)/.local/venvs/
	python3 -m venv $(HOME)/.local/venvs/nvim
	$(HOME)/.local/venvs/nvim/bin/pip install pynvim
	$(HOME)/.local/venvs/nvim/bin/pip install black
	$(HOME)/.local/venvs/nvim/bin/pip install jedi
	vim +UpdateRemotePlugins

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

zsh: zsh-command-not-found zsh-syntax-highlighting zsh-autosuggestions  ## Install all zsh plugins

zsh-command-not-found: $(ZSHRCD)/zsh-command-not-found  ## Install zsh-command-not-found
$(ZSHRCD)/zsh-command-not-found:
	sudo apt install command-not-found
	echo 'source /etc/zsh_command_not_found' > $(ZSHRCD)/zsh-command-not-found

zsh-syntax-highlighting: $(ZSHRCD)/zsh-syntax-highlighting  ## Install zsh-syntax-highlighting
$(ZSHRCD)/zsh-syntax-highlighting:
	sudo apt install zsh-syntax-highlighting
	echo 'source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' > $(ZSHRCD)/zsh-syntax-highlighing.zsh

zsh-autosuggestions: $(XDG_DATA_HOME)/zsh-autosuggestions  ## Install zsh-autosuggestions
$(XDG_DATA_HOME)/zsh-autosuggestions:
	git clone https://github.com/zsh-users/zsh-autosuggestions $(XDG_DATA_HOME)/zsh-autosuggestions
	echo 'source $(XDG_DATA_HOME)/zsh-autosuggestions/zsh-autosuggestions.zsh' > $(ZSHRCD)/zsh-autosuggestions.zsh

powerline10k: $(XDG_DATA_HOME)/powerline10k
$(XDG_DATA_HOME)/powerline10k:
	git clone https://github.com/romkatv/powerlevel10k.git $(XDG_DATA_HOME)/powerline10k
	echo 'source $(XDG_DATA_HOME)/powerline10k/powerlevel10k.zsh-theme' > $(ZSHRCD)/powerlevel10k-source.zsh
	echo 'source $(XDG_CONFIG_DIR)/zsh/p10k.zsh' > $(ZSHRCD)/powerlevel-theme.zsh

fzf: $(XDG_DATA_HOME)/fzf  ## Install fzf with keybindings and autocomplete
$(XDG_DATA_HOME)/fzf:
	git clone --depth 1 https://github.com/junegunn/fzf.git $(XDG_DATA_HOME)/fzf
	$(XDG_DATA_HOME)/fzf/install --bin
	ln -s $(XDG_DATA_HOME)/fzf/bin/fzf $(LOCAL_BIN)/fzf
	ln -s $(XDG_DATA_HOME)/fzf/shell/key-bindings.zsh $(ZSHRCD)/fzf-key-bindings.zsh
	ln -s $(XDG_DATA_HOME)/fzf/shell/completion.zsh $(ZSHRCD)/fzf-completion.zsh

scm_breeze: $(XDG_DATA_HOME)/scm_breeze ./patches/scm_breeze.sh  ## Install and customized scm_breeze
$(XDG_DATA_HOME)/scm_breeze:
	git clone --depth=1 git://github.com/scmbreeze/scm_breeze.git $(XDG_DATA_HOME)/scm_breeze
	cp ./patches/scm_breeze.sh $(XDG_DATA_HOME)/scm_breeze/scm_breeze.sh
	echo 'source "/home/${USER}/.local/share/scm_breeze/scm_breeze.sh"' > $(ZSHRCD)/scm_breeze.zsh

kitty-completion: $(ZSHRCD)/kitty-completion.zsh
$(ZSHRCD)/kitty-completion.zsh:
	echo "kitty + complete setup zsh | source /dev/stdin" > $(ZSHRCD)/kitty-completion.zsh

kitty: $(HOME)/.local/kitty.app/bin/kitty $(HOME)/.local/bin/kitty kitty-completion
$(HOME)/.local/kitty.app/bin/kitty:
	bin/kitty-installer
$(HOME)/.local/bin/kitty:
	ln -s $(HOME)/.local/kitty.app/bin/kitty $(HOME)/.local/bin/kitty

kitty-papercolor:
	mkdir -p $(HOME)/.local/share/kitty/
	git clone https://github.com/craffate/papercolor-kitty.git  $(HOME)/.local/share/kitty/papercolor-kitty

tldr: $(HOME)/.local/bin/tldr
$(HOME)/.local/bin/tldr:
	curl -o ~/.local/bin/tldr https://raw.githubusercontent.com/raylee/tldr/master/tldr
	chmod +x $(HOME)/.local/bin/tldr
	echo 'autoload bashcompinit\nbashcompinit\ncomplete -W "$$(tldr 2>/dev/null --list)" tldr' > $(ZSHRCD)/tldr-completion.zsh

dasht: $(HOME)/.local/share/dasht $(XDG_DATA_HOME)/dasht ## Install dasht cli doc browser
$(XDG_DATA_HOME)/dasht:
	git clone git@github.com:sunaku/dasht.git $(XDG_DATA_HOME)/dasht
	ln -s $(XDG_DATA_HOME)/dasht/bin/* $(LOCAL_BIN)/

pipsi: $(HOME)/.local/bin/pipsi  ## Install pipsi
$(HOME)/.local/bin/pipsi:
	python bin/get-pipsi.py

powerline: pipsi $(PIPSI_VENVS)/powerline-status  # Install powerline
$(PIPSI_VENVS)/powerline-status:
	pipsi install powerline-status

esptool: $(LOCAL_BIN)/esptool.py
$(LOCAL_BIN)/esptool.py:
	pipsi install esptool

awscli: pipsi $(LOCAL_BIN)/aws $(ZSHRCD)/awscli-completion.zsh
$(LOCAL_BIN)/aws:
	pipsi install awscli

$(ZSHRCD)/awscli-completion.zsh:
	echo 'source ${HOME}/.local/bin/aws_zsh_completer.sh' > $(ZSHRCD)/awscli-completion.zsh

nodejs: $(LOCAL_BIN)/node ## Install nodejs stable to .local/share
$(LOCAL_BIN)/node:
	mkdir -p $(HOME)/.local/share/nodejs
	curl https://nodejs.org/dist/v$(NODEJS_VERSION)/node-v$(NODEJS_VERSION)-linux-x64.tar.xz | tar Jxvf - -C $(HOME)/.local/share/nodejs/
	ln -s $(HOME)/.local/share/nodejs/node-v$(NODEJS_VERSION)-linux-x64/bin/node $(LOCAL_BIN)/node
	ln -s $(HOME)/.local/share/nodejs/node-v$(NODEJS_VERSION)-linux-x64/bin/npm $(LOCAL_BIN)/npm

yarn: $(LOCAL_BIN)/yarn
$(LOCAL_BIN)/yarn:
	npm install -g yarn
	ln -s $(HOME)/.local/share/nodejs/node-v$(NODEJS_VERSION)-linux-x64/bin/yarn $(LOCAL_BIN)/yarn

gatsby: nodejs $(LOCAL_BIN)/gatsby ## npm install gatsby global
$(LOCAL_BIN)/gatsby:
	npm install -g gatsby
	ln -s $(HOME)/.local/share/nodejs/node-v$(NODEJS_VERSION)-linux-x64/bin/gatsby $(LOCAL_BIN)/gatsby

serverless: nodejs  $(LOCAL_BIN)/serverless ## npm install serverless global
$(LOCAL_BIN)/serverless:
	npm install -g serverless
	ln -s $(HOME)/.local/share/nodejs/node-v$(NODEJS_VERSION)-linux-x64/bin/serverless $(LOCAL_BIN)/serverless

foundation-cli: nodejs $(LOCAL_BIN)/foundation
$(LOCAL_BIN)/foundation:
	npm install --global foundation-cli
	ln -s $(HOME)/.local/share/nodejs/node-v$(NODEJS_VERSION)-linux-x64/bin/foundation $(LOCAL_BIN)/foundation


micropython: /usr/local/bin/micropython
/usr/local/bin/micropython:
	cd $(HOME)/code/ && git clone git@github.com:micropython/micropython.git
	cd $(HOME)/code/micropython/ports/unix && make
	cd $(HOME)/code/micropython/ports/unix && sudo make install


.PHONY: dialout
dialout:
	sudo usermod -aG dialout $(USER)

/usr/bin/picocom:
	sudo apt install picocom

embedded: micropython esptool dialout /usr/bin/picocom  ## Install embedded chip dev toolchain w/ micropython & esptool

cargo:
	echo 'export CARGO_HOME=$(CARGO_HOME)' > $(ZSHRCD)/rust-cargo.zsh
	echo 'export RUSTUP_HOME=$(RUSTUP_HOME)' >> $(ZSHRCD)/rust-cargo.zsh
	echo 'source $(XDG_DATA_HOME)/cargo/env' >> $(ZSHRCD)/rust-cargo.zsh

rust: $(XDG_DATA_HOME)/cargo/env
$(XDG_DATA_HOME)/cargo/env:
	wget https://sh.rustup.rs -O /tmp/rust-installer
	chmod +x /tmp/rust_installer
	# V likely wont work as it's an interactive cmd
	CARGO_HOME=$(CARGO_HOME) RUSTUP_HOME=$(RUSTUP_HOME) ./install-rust.sh
	echo 'source "$$(XDG_DATA_HOME)/cargo/env)"' > $(ZSHRCD)/rust-cargo.zsh

.DEFAULT_GOAL := help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
