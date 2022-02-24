" ------------------------------------------------------------------------------
" # Configurable Settings
" ------------------------------------------------------------------------------

" Disable autocmds if you wish to manually run tinkeray
if exists('g:tinkeray#disable_autocmds') == 0
  let g:tinkeray#disable_autocmds = 0
endif

" Some environments might require a custom tinker command or path
if exists('g:tinkeray#tinker_command') == 0
  let g:tinkeray#tinker_command = 'php artisan tinker'
endif

" Some environments might require that the tinkeray.php wrapper be copied and run from storage/app
if exists('g:tinkeray#run_from_storage') == 0
  let g:tinkeray#run_from_storage = 0
endif

" Sugar to easily set sail ⛵
function! tinkeray#set_sail(...)
  let service = a:0 ? a:1 : 'laravel.test'
  let g:tinkeray#run_from_storage = 1
  let g:tinkeray#tinker_command = './vendor/bin/sail exec -T -u sail ' . service . ' php artisan tinker storage/app/tinkeray.php'
endfunction


" ------------------------------------------------------------------------------
" # Functions
" ------------------------------------------------------------------------------

let s:plugin_path = expand('<sfile>:p:h:h')
let s:app_path = getcwd()

function! tinkeray#run()
  if g:tinkeray#run_from_storage
    silent exec '!cp -r' s:plugin_path . '/bin/tinkeray.php' s:app_path . '/storage/app/tinkeray.php'
  endif
  if isdirectory(s:app_path.'/vendor/spatie/laravel-ray')
    silent exec '!export TINKERAY_APP_PATH="' . s:app_path . '" &&' g:tinkeray#tinker_command s:plugin_path . '/bin/tinkeray.php'
  else
    echo 'Cannot find [spatie/laravel-ray] package!'
  endif
endfunction

function! tinkeray#open()
  if filereadable(s:app_path . '/tinkeray.php') == 0
    call tinkeray#create_stub()
  endif
  exec 'edit tinkeray.php'
  call search("'tinkeray ready'")
  " call tinkeray#run() " TODO: Only auto run on open when running async
endfunction

function! tinkeray#create_stub()
  call writefile(readfile(s:plugin_path . '/bin/stub.php'), s:app_path . '/tinkeray.php')
endfunction

function! tinkeray#register_autocmds()
  if g:tinkeray#disable_autocmds
    return
  endif
  augroup tinkeray_autocmds
    autocmd!
    autocmd BufEnter tinkeray.php :call tinkeray#open()
    autocmd BufWritePost tinkeray.php :call tinkeray#run()
  augroup END
endfunction
