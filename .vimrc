" Setting up Vundle - the vim plugin bundler
    let iCanHazVundle=1
    let vundle_readme=expand('~/.vim/bundle/vundle/README.md')
    if !filereadable(vundle_readme) 
        echo "Installing Vundle.."
        echo ""
        silent !mkdir -p ~/.vim/bundle
        silent !git clone https://github.com/VundleVim/Vundle.vim ~/.vim/bundle/vundle
        let iCanHazVundle=0
    endif
    set nocompatible              " be iMproved, required
    filetype off                  " required
    set rtp+=~/.vim/bundle/vundle/
    call vundle#begin()
    Plugin 'VundleVim/Vundle.vim'
    "Add your bundles here
    Plugin 'Syntastic' "uber awesome syntax and errors highlighter
    Plugin 'altercation/vim-colors-solarized' "T-H-E colorscheme
    Plugin 'https://github.com/tpope/vim-fugitive' "So awesome, it should be illegal 
    "...All your other bundles...
    Plugin 'vim-airline/vim-airline'
    Plugin 'vim-airline/vim-airline-themes'
    Plugin 'airblade/vim-gitgutter'
    Plugin 'rodjek/vim-puppet'
    Plugin 'davidhalter/jedi-vim'
    Plugin 'vim-scripts/indentpython.vim'       " python indent
    Plugin 'godlygeek/tabular'			" required for vim-markdown
    Plugin 'plasticboy/vim-markdown'		" md plugin
    Plugin 'vimwiki/vimwiki'
    Plugin 'Valloric/YouCompleteMe'             " python autocomplete

    if iCanHazVundle == 0
        echo "Installing Vundles, please ignore key map error messages"
        echo ""
        :PluginInstall
    endif

    call vundle#end() 
    "must be last
    filetype plugin indent on " load filetype plugins/indent settings

    " colorscheme solarized
    set t_Co=256
    colorscheme wombat256mod
    syntax on                      " enable syntax

    "airline
    set laststatus=2 "force to appear

    " gitgutter
    set updatetime=250

    " set incr search
    set incsearch

    " disable .swp
    set noswapfile

    set cursorline
    set cursorcolumn

    :map <F6> :w<CR>:silent !chmod +x %:p<CR>:silent !%:p 2>&1 \| tee /tmp/%:t.tmp<CR>:pedit! +:42343234 /tmp/%:t.tmp<CR>:redraw!<CR><CR>n

    set encoding=utf-8

    " yaml
    autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

    " debug youcompleteme
    let g:ycm_keep_logfiles = 1
    let g:ycm_log_level = 'debug'

    " indent several lines in visual mode 
    xnoremap <Tab> >gv
    xnoremap <S-Tab> <gv

    " list and select buffers
    :nnoremap <F5> :buffers<CR>:buffer<Space>

    " vim-markdown github/gitlab compat
    let g:vim_markdown_no_extensions_in_markdown = 1

" Setting up Vundle - the vim plugin bundler end
