#!/bin/bash
########### 
##
## Syncing with github 

### Vars
LOCATION="/scripts/"
VERBOSE=/dev/null
if [ ! -d $LOCATION ]; then
	mkdir $LOCATION
fi
# Git
GIT_URL="git@github.com:s4mur4i/leats-scripts.git"
USERNAME="gruberrichard"
EMAIL="gruberrichard@gmail.com"
EDITOR=vim
DIFF=vimdiff
PUSH=0
PULL=0
### Helpers
# Git global opts
git config --global user.name $USERNAME
git config --global user.email $EMAIL
git config --global core.editor $EDITOR
git config --global merge.tool $DIFF
git config --global core.excludesfile /root/.gitignore

help() {
	cat << EOF
usage: $0 -v -p -c
-v		verbose
-p 		get changes
-c		push changes
EOF
}

pull() {
git pull
}

push() {
git push origin master
}
### Opts

while getopts “vhpc” OPTION
do
     case $OPTION in
         v)
	   VERBOSE=/dev/stdout
	   ;;
	 h)
	   help
	   exit 0
           ;;
	 p)
	   PUSH=1
	   ;;
	 c)
	   PULL=1
	   ;;
	 *)
	   echo "Unknown Parameter."
	   exit 1
     esac
done
### Main
if [[ (( $PULL -eq 1 ))  && (( $PUSH -eq 1 )) ]] ; then
	echo "Pull and Push cannot be defined at once."
	exit 2
fi
cd $LOCATION
if [ ! -d .git ]; then
	echo "Initialised Git." >$VERBOSE 2>&1
	cd /
	git clone $GIT_URL $LOCATION
else 
	echo "Directory already initialiased." >$VERBOSE 2>&1
fi
if [[ $PULL -eq 1 ]]; then
	echo "Pulling changes" >$VERBOSE 2>&1
	pull
fi
if [[ $PUSH -eq 1 ]]; then
	echo "Pushing changes" >$VERBOSE 2>&1
	push
fi

