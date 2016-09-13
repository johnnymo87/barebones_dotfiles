" Turn off vi compatibility
set nocompatible

" ================ Turn Off Swap Files ==============

set noswapfile
set nobackup
set nowb

" ================ Indentation ======================
set expandtab
set shiftwidth=2
set softtabstop=2
set smartindent
set autoindent

" load indent file for the current filetype
filetype indent on

" turn on syntax highlighting
syntax enable

" Change leader to a comma because the backslash is too far away
" That means all \x commands turn into ,x
" The mapleader has to be set before vundle starts loading all 
" the plugins.
let mapleader=","

" Display tabs and trailing spaces visually
set list listchars=tab:\ \ ,trail:·

set number       "Line numbers are good
set backspace=indent,eol,start  "Allow backspace in insert mode
set nowrap       "Don't wrap lines
set linebreak    "Wrap lines at convenient points
set visualbell                  "No sounds

" ================ Folds ============================

set foldmethod=indent   "fold based on indent
set foldnestmax=3       "deepest fold is 3 levels
set nofoldenable        "dont fold by default

" ================ Custom Settings ========================

set shell=/bin/sh

nnoremap ,db :normal orequire 'pry'; binding.pry<ESC>

set iskeyword-=_ "recognize underscore as word break

set colorcolumn=81,82,83 "vertical bar at right of column 80

nnoremap ,l :update<cr>

nnoremap ,cp :let @+=@%<CR> " copy current file's path to system buffer

" In normal mode or in insert mode, press Alt-j to move the current line down, or
" press Alt-k to move the current line up.
"
" After visually selecting a block of lines (for example, by pressing V then
" moving the cursor down), press Alt-j to move the whole block down, or press
" Alt-k to move the block up.

nnoremap ∆ :m .+1<CR>==
nnoremap ˚ :m .-2<CR>==
inoremap ∆ > <Esc>:m .+1<CR>==gi
inoremap ˚ <Esc>:m .-2<CR>==gi
vnoremap ∆ :m '>+1<CR>gv=gv
vnoremap ˚ :m '<-2<CR>gv=gv

function! RunSpec(runner, fileAndLineNumber)
  exe 'wa'
  exe a:runner . ' rspec ' . a:fileAndLineNumber . ' --format documentation --color'
endfunction

function! RunCuke(runner, fileAndLineNumber)
  exe 'wa'
  exe a:runner . ' cucumber ' . a:fileAndLineNumber . ' -r features/'
endfunction

function! RunHspec(runner, file)
  exe 'wa'
  exe a:runner . ' runhaskell ' . a:file
endfunction

function! RunRakeDbTestPrepare()
  exe 'wa'
  exe 'Dispatch rake db:test:prepare'
endfunction

function! StripLineNumber(fileAndLineNumber)
  return substitute(a:fileAndLineNumber, '\(:.*\)', '', '')
endfunction

function! OpenParens()
  s:(:(\r
  s:):\r)
  normal k
  s:,:,\r:g
  noh
  normal jv%=
endfunction

nnoremap ,1w :call OpenParens()<CR>

function! OpenCurlies()
  s:{:do\r:
  s: }:\rend:
  normal v%=j
  noh
endfunction

nnoremap ,1s :call OpenCurlies()<CR>

function! FindSourceOrSpec()
  if match(@%, '\v^app/assets/javascripts/') != -1
    return substitute(@%, '\v^(app/assets/javascripts/)(.*)(\.es6)$', 'app/assets/test/\2.spec.es6', '')
  elseif match(@%, '\v\.spec\.es6') != -1
    return substitute(@%, '\v^(app/assets/test/)(.*)(\.spec\.es6)$', 'app/assets/javascripts/\2.es6', '')
  elseif match(@%, '\v_spec\.rb') != -1
    return substitute(@%, '\v^(spec)(.*)(_spec\.rb)$', 'app\2.rb', '')
  elseif match(@%, '\v^app.*\.rb') != -1
    return substitute(@%, '\v^(app)(.*)(\.rb)$', 'spec\2_spec.rb', '')
  endif
endfunction

nnoremap ,ss :exe 'vsp ' . FindSourceOrSpec()<CR>

nnoremap ,oo :let @f= @% . ':' . line('.')<CR>
nnoremap ,8p :call RunSpec('Dispatch', StripLineNumber(@f))<CR>
nnoremap ,p :call RunSpec('Dispatch', @f)<CR>
nnoremap ,0p :call RunSpec('!', @f)<CR>
nnoremap ,9p :call RunSpec('!', StripLineNumber(@f))<CR>
nnoremap ,0k :call RunHspec('!', StripLineNumber(@f))<CR>

nnoremap ,uu :let @g= @% . ':' . line('.')<CR>
nnoremap ,8i :call RunCuke('Dispatch', StripLineNumber(@g))<CR>
nnoremap ,i :call RunCuke('Dispatch', @g)<CR>
nnoremap ,0i :call RunCuke('!', @g)<CR>
nnoremap ,9i :call RunCuke('!', StripLineNumber(@g))<CR>

nnoremap ,yy :call RunRakeDbTestPrepare()<CR>

" associate *.es6 with javascript filetype
au BufRead,BufNewFile *.es6 set filetype=javascript

" associate *.json with json filetype
au BufRead,BufNewFile *.json set filetype=json

" use jsx syntax plugin on non-.jsx files
let g:jsx_ext_required = 0

" use custom js linter from https://github.com/jaxbot/syntastic-react
let g:syntastic_javascript_checkers = ['eslint']
let g:syntastic_json_checkers=['jsonlint']
