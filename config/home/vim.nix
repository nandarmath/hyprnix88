{pkgs, config, ...}:
{
programs.vim = {
    enable = true;
    extraConfig = ''
      set mouse =a
      syntax on
      set number
      set relativenumber
      set cursorline
      :highlight Cursorline cterm=bold ctermbg=black
      set hlsearch
      set ignorecase
      set smartcase
      set tabstop     =4
      set softtabstop =4
      set shiftwidth  =4
      set textwidth   =79
      set expandtab
      set autoindent
      set showmatch
      autocmd BufWritePre *.py :%s/\s\+$//e
      autocmd BufWritePre *.f90 :%s/\s+$//e
      autocmd BufWritePre *.f95 :%s/\s+$//e
      autocmd BufWritePre *.for :%s/\s+$//e

      if !has('gui_running')
            set t_Co=256
      endif

      set termguicolors
      colorscheme desert


    '';
    
  };






}
