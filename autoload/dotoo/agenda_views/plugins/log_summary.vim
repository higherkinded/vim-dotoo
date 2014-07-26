if exists('g:autoloaded_dotoo_agenda_log_summary')
  finish
endif
let g:autoloaded_dotoo_agenda_log_summary = 1

" Log Summary Agenda Plugin {{{1
function! s:log_line(title, time, pad) "{{{2
  let [time, title] = [a:time, a:title]
  if a:pad | let [time, title] = [' '.time.' ', ' '.title.' '] | endif
  return printf('|%-50.50s|%10s|', title, time)
endfunction

function! s:line_separator() "{{{2
  return s:log_line(repeat('-',50), repeat('-',10), 0)
endfunction

function! s:build_summaries(date, dotoo_values) "{{{2
  let all_summaries = []
  for dotoo in values(a:dotoo_values)
    let summaries = []
    let total = 0
    let dotoo_summaries = dotoo.log_summary(a:date, 'day')
    for dotoo_summary in dotoo_summaries
      call add(summaries,
            \  s:log_line(dotoo_summary[0],
            \            dotoo_summary[1].to_string(g:dotoo#time#time_format),
            \            1))
      let total += dotoo_summary[1].to_seconds() + dotoo_summary[1].datetime.stzoffset
    endfor
    if !empty(summaries)
      call insert(summaries, s:log_line(dotoo.key, dotoo#time#new(total).to_string(g:dotoo#time#time_format), 1))
      call add(summaries, s:line_separator())
      call extend(all_summaries, summaries)
    endif
  endfor
  if !empty(all_summaries) | call insert(all_summaries, s:line_separator()) | endif
  call insert(all_summaries, 'Log Summary')
  return all_summaries
endfunction

let s:plugin_name = 'log_summary'
let s:log_summary_plugin = {'showing': 0}
function! s:log_summary_plugin.map() dict "{{{2
  exec 'nnoremap <buffer> <silent> <nowait> R :<C-U>call dotoo#agenda_views#agenda#toggle_plugin("' . s:plugin_name . '")<CR>'
endfunction

function! s:log_summary_plugin.setup() dict
  call self.map()
endfunction

function! s:log_summary_plugin.content(date, agenda_dotoos) dict "{{{2
  if self.showing
    return s:build_summaries(a:date, a:agenda_dotoos)
  endif
  return []
endfunction

function! s:log_summary_plugin.cleanup() dict
  call self.unmap()
endfunction

function! dotoo#agenda_views#plugins#log_summary#register() "{{{1
  call dotoo#agenda_views#agenda#register_plugin(s:plugin_name, s:log_summary_plugin)
endfunction
