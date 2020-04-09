call plug#begin('~/.vim/plugged')

let rplugin = {}
function! rplugin.do(info)
  UpdateRemotePlugins
endfunction

Plug 'crusoexia/vim-monokai'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'scrooloose/nerdtree'
" For async completion
Plug 'Shougo/deoplete.nvim', rplugin
" For Denite features
Plug 'Shougo/denite.nvim'
call plug#end()


"enable line numbers in nerdtree
let NERDTreeShowLineNumbers = 1
autocmd FileType nerdtree setlocal number

"ignore patters from gitignore when fuzzy searching with fzf
let $FZF_DEFAULT_COMMAND = 'git ls-files'

"enable deoplete at startup
let g:deoplete#enable_at_startup = 1

filetype plugin indent on

syntax on
set t_Co=256
colorscheme monokai
hi Normal guibg=NONE ctermbg=NONE

set number relativenumber

set ignorecase smartcase

set autoindent
set expandtab
set softtabstop=2
set shiftwidth=2
set shiftround

set showcmd

set hlsearch

set ttyfast
set lazyredraw

set splitbelow
set splitright

set cursorline
set wrapscan
set laststatus=2 
set report=0

" mouse scroll
set mouse=a

set splitbelow
set splitright

map <Tab> :NERDTreeToggle<CR>

nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

inoremap " ""<left>
inoremap ' ''<left>
inoremap ( ()<left>
inoremap [ []<left>
inoremap { {}<left>
inoremap {<CR> {<CR>}<ESC>O
inoremap {;<CR> {<CR>};<ESC>O