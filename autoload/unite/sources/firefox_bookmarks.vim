
function! unite#sources#firefox_bookmarks#define()
  return s:source
endfunction

let s:source = {
      \ 'name'           : 'firefox/bookmarks',
      \ 'action_table'   : {},
      \ 'default_action' : {'common' : 'execute'},
      \ }

function! s:source.gather_candidates(args, context)

  let candidates = []
  for bookmark in s:get_bookmarks()
    call add(candidates, {
          \ 'word'             : bookmark.title,
          \ 'source__bookmark' : bookmark,
          \ })
  endfor

  return candidates
endfunction


let s:source.action_table.execute = {'description' : 'open browser'}
function! s:source.action_table.execute.func(candidate)
  call openbrowser#open(a:candidate.source__bookmark.uri)
endfunction



function! s:get_bookmarks()
  let path = expand('~') . '/Library/Application\ Support/Firefox/Profiles/**'
  let path = finddir('bookmarkbackups', path)
  let path = sort(split(glob(path . '/*.json'), '\n'))[-1]

  let json =  webapi#json#decode(readfile(path)[0])
  return s:read_bookmarks(json)
endfunction


function! s:read_bookmarks(root)
  if !has_key(a:root, 'children')
    return [a:root]
  endif
  let bookmarks = []
  for child in a:root.children
    call extend(bookmarks, s:read_bookmarks(child))
  endfor
  return bookmarks
endfunction
