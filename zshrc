# Completion
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select
setopt completeinword
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' matcher-list '' \
  'm:{a-z\-}={A-Z\_}' \
  'r:[^[:alpha:]]||[[:alpha:]]=** r:|=* m:{a-z\-}={A-Z\_}' \
  'r:|?=** m:{a-z\-}={A-Z\_}'

# Colors and prompt
autoload -Uz colors && colors
autoload -Uz promptinit
promptinit
if [[ -x "`whence -p dircolors`" ]]; then
  eval `dircolors`
  alias ls='ls --color=tty'
else
  alias ls='ls -F'
fi


alias w3mpan='tmux new-session -s browse w3m'

# Editor
export EDITOR=vim
export BROWSER=chromium
# export BROWSER=chromium

# History
#
setopt inc_append_history
setopt share_history
#setopt APPEND_HISTORY
SAVEHIST=10000
HISTSILZE=10000
HISTFILE=~/.cache/zsh_history

# Git prompt
setopt prompt_subst
#autoload colors zsh/terminfo
#colors
function __git_prompt {
  local DIRTY="%{$fg[red]%}"
  local CLEAN="%{$fg[green]%}"
  local UNMERGED="%{$fg[magenta]%}"
  local RESET="%{$terminfo[sgr0]%}"
  git rev-parse --git-dir >& /dev/null
  if [[ $? == 0 ]]
  then
    echo -n ""
    if [[ `git ls-files -u >& /dev/null` == '' ]]
    then
      git diff --quiet >& /dev/null
      if [[ $? == 1 ]]
      then
        echo -n $DIRTY" ["
      else
        git diff --cached --quiet >& /dev/null
        if [[ $? == 1 ]]
        then
          echo -n $DIRTY" ["
        else
          echo -n $CLEAN" ["
        fi
      fi
    else
      echo -n $UNMERGED
    fi
    echo -n `git branch | grep '* ' | sed 's/..//'`
	echo -n "]"
#	#echo -n $RESET
  fi
}

# Left prompt
GIT='$(__git_prompt)'
if [[ -z "$SSH_CLIENT" ]]; then
        prompt_host=""
else
		prompt_host=%{$fg_no_bold[magenta]%}%n%{$reset_color%}@%{$fg_no_bold[purple]%}%m
fi

PROMPT="$prompt_host %{$fg_bold[blue]%}%~$GIT %{$fg_no_bold[magenta]%}➤%{$fg_no_bold[green]%} %{$reset_color%}"
#PROMPT="$prompt_host %{$fg_bold[blue]%}%~$GIT %{$fg_no_bold[white]%}%# %{$reset_color%}"

zstyle ':completion:*' list-colors "${(@s.:.)LS_COLORS}"

alias grep='grep --color=auto'

# Globbing
setopt extended_glob
