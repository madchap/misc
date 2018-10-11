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
Plugin 'scrooloose/nerdtree'
Plugin 'Xuyuanp/nerdtree-git-plugin'
Plugin 'Valloric/YouCompleteMe'             " python autocomplete
Plugin 'saltstack/salt-vim'

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

" executes script
:map <F6> :w<CR>:silent !chmod +x %:p<CR>:silent !%:p 2>&1 \| tee /tmp/%:t.tmp<CR>:pedit! +:42343234 /tmp/%:t.tmp<CR>:redraw!<CR><CR>n

set encoding=utf-8

" yaml
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

" YouCompleteMe
" debug youcompleteme
" let g:ycm_keep_logfiles = 1
" let g:ycm_log_level = 'debug'
let g:ycm_autoclose_preview_window_after_completion=1
map <leader>g  :YcmCompleter GoToDefinitionElseDeclaration<CR>
let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_autoclose_preview_window_after_insertion = 1
let g:ycm_key_list_select_completion = ['<TAB>', '<DOWN>']
let g:ycm_key_list_previous_completion = ['<S-TAB>', '<UP>']
let g:ycm_key_list_stop_completion = ['<C-y>', '<ENTER>']

py << EOF
import os
import sys
if 'VIRTUAL_ENV' in os.environ:
    project_base_dir = os.environ['VIRTUAL_ENV']
    activate_this = os.path.join(project_base_dir, 'bin/activate')
    execfile(activate_this, dict(__file__=activate_this))
EOF


" indent several lines in visual mode 
xnoremap <Tab> >gv
xnoremap <S-Tab> <gv

" md fold level
set foldlevel=5

" list and select buffers
:nnoremap <F5> :buffers<CR>:buffer<Space>

" vimwiki options
let mywiki = {}
let mywiki.path = '~/gitrepos/mywiki'
let mywiki.path_htlm = '~/gitrepos/mywiki_html'
let g:vimwiki_list = [mywiki]

let g:vimwiki_autowriteall = 1

" nerdtree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif " close vim if only nerdtree 
map <C-n> :NERDTreeToggle<CR>

" .py header
au BufNewFile *.py 0r ~/gitrepos/misc/scripts/vim_python_header.txt
