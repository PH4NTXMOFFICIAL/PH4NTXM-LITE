# PH4NTXM Terminal
autoload -Uz colors && colors
setopt prompt_subst

C_ICE='%F{39}'
C_PURPLE='%F{201}'
C_ERR='%F{160}'
C_TXT='%F{250}'
C_RESET='%f'

context() {
  echo "${C_ICE}[PH4NTXM]${C_RESET}"
}

git_branch() {
  local b
  b=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || return
  if ! git diff --quiet --ignore-submodules -- 2>/dev/null \
     || ! git diff --cached --quiet --ignore-submodules -- 2>/dev/null; then
    echo " ${C_ERR}($b ✘)${C_RESET}"
  else
    echo " ${C_PURPLE}($b)${C_RESET}"
  fi
}

exit_status() {
  local s=$?
  [[ $s -ne 0 ]] && echo "${C_ERR}✘$s${C_RESET} "
}

current_dir() {
  print -P "%~"
}

PROMPT='${C_ICE}┌─ $(context) | $(current_dir)$(git_branch)
${C_ICE}└─⮞ ${C_RESET}'
RPROMPT='$(exit_status)${C_TXT}%*${C_RESET}'

setopt auto_cd
setopt correct
setopt interactivecomments

export HISTFILE=~/.zsh_history
export HISTSIZE=100
export SAVEHIST=100
setopt share_history
setopt hist_ignore_all_dups
setopt hist_ignore_space

echo -e "\033[1;36m[+] PH4NTXM Terminal initialized.\033[0m"