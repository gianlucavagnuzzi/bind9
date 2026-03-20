#!/bin/bash
set -x

# put here dirs that must be made persistent
list_dirs() {
cat <<EOF
#/dirs/tobe/make/persistent
EOF
}

outListDirs=$(list_dirs | grep -v ^#)

function _dirs {
DEST_PATH="/data"

if [ ! -z $outListDirs ]; then

 echo "--------------------------------------"
 echo " Moving persistent data in $DEST_PATH "
 echo "--------------------------------------"

 list_dirs | while read path_name DUMMY; do
  if [ ! -e ${DEST_PATH}${path_name} ]; then
   if [ -d $path_name ]; then
    rsync -Ra ${path_name}/ ${DEST_PATH}/
   else
    rsync -Ra ${path_name} ${DEST_PATH}/
   fi
  else
   echo "---------------------------------------------------------"
   echo " No NEED to move anything for $path_name in ${DEST_PATH} "
   echo "---------------------------------------------------------"
  fi
  rm -rf ${path_name}
  ln -s ${DEST_PATH}${path_name} ${path_name}
 done
fi
}

function _main {
 # if it is first execution, put default files in /data dir
 if [ ! -e ${DEST_PATH}/.initialized ]; then
  [ -e "/data/named.conf" ] || cp "/template/named.conf" "/data/"
  [ -e "/data/db.mydomain.lan.zone" ] || cp "/template/db.mydomain.lan.zone" "/data"
  [ -e "/data/db.192.168.0.zone" ] || cp "/template/db.192.168.0.zone" "/data"
  touch ${DEST_PATH}/.initialized
 fi

 chown -R 100:100 /data
 # define CMD to be launched
 #CMD="/usr/sbin/named -u bind -g -c /data/named.conf"
}

custom_bashrc() {
cat <<'EOF'
export LS_OPTIONS="--color=auto"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -la'
alias l='ls $LS_OPTIONS -lA'

# prompt SOLO per shell interattive
if [[ $- == *i* ]]; then
  if [ "$(id -u)" -eq 0 ]; then
    PS1="\[\e[35m\][\[\e[31m\]\u\[\e[36m\]@\[\e[32m\]\h\[\e[90m\] \w\[\e[35m\]]\[\e[0m\]# "
  else
    PS1="\[\e[35m\][\[\e[33m\]\u\[\e[36m\]@\[\e[32m\]\h\[\e[90m\] \w\[\e[35m\]]\[\e[0m\]$ "
  fi
  export PS1
fi
EOF
}

setup_bashrc() {
  for home in /root /home/*; do
    [ -d "$home" ] || continue
    bashrc="$home/.bashrc"

    # crea se manca
    [ -f "$bashrc" ] || touch "$bashrc"

    # evita duplicazioni
    grep -q '### CUSTOM BASHRC ###' "$bashrc" && continue

    {
      echo ''
      echo '### CUSTOM BASHRC ###'
      custom_bashrc
    } >> "$bashrc"
  done
}


_dirs
_main

setup_bashrc

# print cmd that will be executed
echo "Starting: $*" >&2

# launch CMD
exec "$@"


