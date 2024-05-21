" syntax: :Veracode
command! Veracode call RunCmd()

function! RunCmd()
  " Read JSON configuration file
  let json_content = join(readfile(expand('~/.vim/plugin/veracode/config.json')), "\n")

  " Parse JSON content to extract values
  let config = json_decode(json_content)

  " Assign values to variables
  let app_path = config.app_path
  let package_path = config.package_path
  let exclude_dir = ""   " config.exclude_dir

  " Package up app for scanning
  call CreateAppPackage(package_path, app_path, exclude_dir)

  " Run Scan
  call RunScan(package_path)
  echom "[+] Scan Complete!"
endfunction

function! CreateAppPackage(package_path, app_path, exclude_dir)
  if exists(a:exclude_dir) && config.exclude_dir != ""
      let l:package_command = "rm -f " . a:package_path . " && cd ~/dev/scratch && zip -r " . a:package_path . " " . a:app_path -D a:exclude_dir
  else
    " If no exclude_dir is set, run regular.
    let l:package_command = "rm -f " . a:package_path . " && cd ~/dev/scratch && zip -r " . a:package_path . " " . a:app_path
  endif

  " Combine the command and directory path
  "let l:package_command = "rm -f " . a:package_path . " && zip -r " . a:package_path . " " . a:app_path

  " Run the system command and capture the output
  let l:output = system(l:package_command)

  " Check if there was an error executing the command
  if v:shell_error
    echohl ErrorMsg
    echom "Error running command: ".l:package_command
    echohl None
    return
  endif
  echom "[+] App packaged up!"
endfunction

function! RunScan(package_path)
  echom "[+] Starting scan..."
  " Another system command to run
  let l:scan_command = 'veracode static scan ' . a:package_path
  " Run the another system command and capture the output
  let l:scan_output = system(l:scan_command)

  " Open a new vertical split window and create an empty buffer
  rightbelow vsplit
  enew
  setlocal buftype=nofile
  setlocal bufhidden=wipe
  setlocal noswapfile

  " Insert the command output into the new buffer
  call setline(1, split(l:scan_output, "\n"))
  " Window width
  vertical resize 50
endfunction
