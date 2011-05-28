let s:save_cpo = &cpo
set cpo&vim

" Variables  "{{{
call unite#util#set_default('g:unite_source_li3_ignore_pattern',
      \'^\%(/\|\a\+:/\)$\|\%(^\|/\)\.\.\?$\|empty$\|\~$\|\.\%(o|exe|dll|bak|sw[po]\)$')
"}}}

let s:places = [
      \ {'name' : 'app'         , 'path' : '/app'                   } ,
      \ {'name' : 'config'      , 'path' : '/app/config'            } ,
      \ {'name' : 'controllers' , 'path' : '/app/controllers'       } ,
      \ {'name' : 'extensions'  , 'path' : '/app/extensions'        } ,
      \ {'name' : 'helper'      , 'path' : '/app/extensions/helper' } ,
      \ {'name' : 'data'        , 'path' : '/app/extensions/data'   } ,
      \ {'name' : 'libraries'   , 'path' : '/app/libraries'         } ,
      \ {'name' : 'models'      , 'path' : '/app/models'            } ,
      \ {'name' : 'resources'   , 'path' : '/app/resources'         } ,
      \ {'name' : 'g11n'        , 'path' : '/app/resources/g11n'    } ,
      \ {'name' : 'tmp'         , 'path' : '/app/resources/tmp'     } ,
      \ {'name' : 'tests'       , 'path' : '/app/tests'             } ,
      \ {'name' : 'views'       , 'path' : '/app/views'             } ,
      \ {'name' : 'layouts'     , 'path' : '/app/views/layouts'     } ,
      \ {'name' : 'webroot'     , 'path' : '/app/webroot'           } ,
      \ {'name' : 'js'          , 'path' : '/app/webroot/js'        } ,
      \ {'name' : 'css'         , 'path' : '/app/webroot/css'       } ,
      \  ]

let s:source = {}

function! s:source.gather_candidates(args, context)
  return s:create_sources(self.path)
endfunction

" li3/command
"   history
"   [command] li3

let s:source_command = {}

function! unite#sources#li3#define()
  return map(s:places ,
        \   'extend(copy(s:source),
        \    extend(v:val, {"name": "li3/" . v:val.name,
        \   "description": "candidates from history of " . v:val.name}))')
endfunction

function! s:create_sources(path)
  let root = s:li3_root()
  if root == "" | return [] | end
  let files = map(split(globpath(root . a:path , '**') , '\n') , '{
        \ "name" : fnamemodify(v:val , ":t:r") ,
        \ "path" : v:val
        \ }')

  let list = []
  for f in files
    if isdirectory(f.path) | continue | endif

    if g:unite_source_li3_ignore_pattern != '' &&
          \ f.path =~  string(g:unite_source_li3_ignore_pattern)
        continue
    endif

    call add(list , {
          \ "abbr" : substitute(f.path , root . a:path . '/' , '' , ''),
          \ "word" : substitute(f.path , root . a:path . '/' , '' , ''),
          \ "kind" : "file" ,
          \ "action__path"      : f.path ,
          \ "action__directory" : fnamemodify(f.path , ':p:h:h') ,
          \ })
  endfor

  return list
endfunction

function! s:li3_root()
  let dir = finddir("app" , ".;")
  if dir == "" | return "" | endif
  return  dir . "/../"
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

