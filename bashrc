alias via2="vim $BASHRC_SHARED2;source $BASHRC_SHARED2"

function branches() {
  tput setaf 3;tput bold;
  echo =====================================================================================
  tput sgr0

  tput bold
  cat ~/proj/branches/branches.txt
  tput sgr0
}
alias vibr='[[ -d ~/proj/branches ]] || mkdir ~/proj/branches ; vim ~/proj/branches/branches.txt'
