{ pkgs, ... }:

# [here some aliases, you can change it if you dont like it, but everything works]

{
  programs.bash = {
    enable = true;
    initExtra = ''
      export PS1="\[\033[1;34m\][\w]\[\033[0m\] "
    '';
    shellAliases = {
      rebuild = "doas nixos-rebuild switch --flake /etc/nixos#morphine";
      v = "vim";
      larp = "fastfetch";
      conf = "doas vim /etc/nixos/hosts/morphine/configuration.nix";
      home = "doas vim /etc/nixos/home/ravyc/home.nix";
      shell = "doas vim /etc/nixos/home/ravyc/programs/default.nix";
      flake = "doas vim /etc/nixos/flake.nix";
      wm = "doas vim /home/ravyc/.config/sway/config";
      terminal = "doas vim /home/ravyc/.config/foot/foot.ini";
      snake = "python3 ";
      revive = "doas nix-channel --update";
      clean = "doas nix-collect-garbage -d";
      boot = "doas /nix/var/nix/profiles/system/bin/switch-to-configuration boot";
    };
  };

# [you can change some things here, just if you know what are you doing]

  home.file.".vimrc".text = ''
    call plug#begin('~/.vim/plugged')
    Plug 'joshdick/onedark.vim'
    Plug 'catppuccin/vim', { 'as': 'catppuccin' }
    Plug 'preservim/nerdtree'
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
    Plug 'jiangmiao/auto-pairs'
    Plug 'sheerun/vim-polyglot'
    call plug#end()

    let g:airline_theme='catppuccin_macchiato'
    syntax on
    set clipboard=unnamedplus
    set number relativenumber
    set mouse=a
    set encoding=utf-8
    set noswapfile
    set nobackup
    set tabstop=4
    set softtabstop=4
    set shiftwidth=4
    set expandtab
    set autoindent
    set smartindent
    set hlsearch
    set incsearch
    set ignorecase
    set smartcase
    set scrolloff=8
    set showmode
    set wildmenu

    let mapleader = " "
    nnoremap <leader>c :nohlsearch<CR>
    nnoremap <leader>w :w<CR>
    nnoremap <C-h> <C-w>h
    nnoremap <C-j> <C-w>j
    nnoremap <C-k> <C-w>k
    nnoremap <C-l> <C-w>l
  '';
}
