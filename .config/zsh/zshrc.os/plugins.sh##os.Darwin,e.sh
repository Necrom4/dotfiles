# -- VI-MODE --

function zvm_vi_yank() {
  zvm_yank
  echo ${CUTBUFFER} | clipcopy
  zvm_exit_visual_mode
}
