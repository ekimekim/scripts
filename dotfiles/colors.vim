" Vim color file

" First remove all existing highlighting.
set background=light
hi clear
if exists("syntax_on")
  syntax reset
endif

let colors_name = "custom"

hi Normal ctermfg=NONE ctermbg=NONE cterm=NONE

hi SpecialKey   ctermfg=4    ctermbg=NONE cterm=NONE
hi NonText      ctermfg=4    ctermbg=NONE cterm=bold
hi Directory    ctermfg=4    ctermbg=NONE cterm=NONE
hi ErrorMsg     ctermfg=7    ctermbg=1    cterm=bold
hi IncSearch    ctermfg=NONE ctermbg=NONE cterm=reverse
hi Search       ctermfg=0    ctermbg=3    cterm=NONE
hi MoreMsg      ctermfg=2    ctermbg=NONE cterm=NONE
hi ModeMsg      ctermfg=NONE ctermbg=NONE cterm=bold
hi LineNr       ctermfg=3    ctermbg=NONE cterm=NONE
hi Question     ctermfg=2    ctermbg=NONE cterm=NONE
hi StatusLine   ctermfg=NONE ctermbg=NONE cterm=bold,reverse
hi StatusLineNC ctermfg=NONE ctermbg=NONE cterm=reverse
hi VertSplit    ctermfg=NONE ctermbg=NONE cterm=reverse
hi Title        ctermfg=5    ctermbg=NONE cterm=NONE
hi Visual       ctermfg=NONE ctermbg=NONE cterm=reverse
hi VisualNOS    ctermfg=NONE ctermbg=NONE cterm=bold,underline
hi WarningMsg   ctermfg=1    ctermbg=NONE cterm=NONE
hi WildMenu     ctermfg=0    ctermbg=3    cterm=NONE
hi Folded       ctermfg=4    ctermbg=7    cterm=NONE
hi FoldColumn   ctermfg=4    ctermbg=7    cterm=NONE
hi DiffAdd      ctermfg=6    ctermbg=NONE cterm=NONE
hi DiffChange   ctermfg=5    ctermbg=NONE cterm=NONE
hi DiffDelete   ctermfg=5    ctermbg=NONE cterm=NONE
hi DiffText     ctermfg=NONE ctermbg=1    cterm=bold
hi MatchParen   ctermfg=red  ctermbg=NONE cterm=NONE

" Colors for syntax highlighting
hi Comment    ctermfg=4    ctermbg=NONE cterm=NONE
hi Constant   ctermfg=1    ctermbg=NONE cterm=NONE
hi Special    ctermfg=5    ctermbg=NONE cterm=NONE
hi Identifier ctermfg=6    ctermbg=NONE cterm=NONE
hi Statement  ctermfg=3    ctermbg=NONE cterm=NONE
hi PreProc    ctermfg=5    ctermbg=NONE cterm=NONE
hi Type       ctermfg=2    ctermbg=NONE cterm=NONE
hi Ignore     ctermfg=7    ctermbg=NONE cterm=bold
hi Error      ctermfg=7    ctermbg=1    cterm=bold
hi Todo       ctermfg=0    ctermbg=3    cterm=NONE
