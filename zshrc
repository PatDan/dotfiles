# Completion
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select
setopt completeinword
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

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

# Editor
export EDITOR=vim

# History
setopt APPEND_HISTORY
SAVEHIST=100
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
#GIT='$(__git_prompt)'
PROMPT="%{$fg_no_bold[magenta]%}%n%{$reset_color%}@%{$fg_no_bold[purple]%}%m %{$fg_bold[blue]%}%1~$GIT %{$reset_color%}%# "
#if [[ -z "$SSH_CLIENT" ]]; then
#else
	#PROMPT="%{$fg_no_bold[yellow]%}%n%  %{$fg_bold[blue]%}%1~$GIT %{$reset_color%}%# "
#fi


zstyle ':completion:*' list-colors "${(@s.:.)LS_COLORS}"
