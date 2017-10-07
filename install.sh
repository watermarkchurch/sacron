#! /bin/bash

COLOR_OFF='\033[0m'       # Text Reset
COLOR_GREEN='\033[0;32m'
COLOR_RED='\033[0;31m'
COLOR_YELLOW='\033[0;33m' 
COLOR_CYAN='\033[0;36m'

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

BIN_DIR=/bin

usage() { echo -e "`basename $0` ${COLOR_YELLOW}<flags>${COLOR_OFF}
  Installs sacron and associated dependencies

${COLOR_YELLOW}Flags:${COLOR_OFF}" && grep " .)\ #" $0; }

while getopts ":d:h" opt; do
  case $opt in
    h) # print the help
      usage
      exit 0
      ;;
    d) # The directory to install sacron
      BIN_DIR=$OPTARG
      ;;
    \?)
      echo -e "${COLOR_RED}Invalid option: -$OPTARG${COLOR_OFF}" >&2
      usage
      exit -1
      ;;
  esac
done

[[ ! -d $BIN_DIR ]] && echo -e "${COLOR_RED}Install directory ${BIN_DIR} does not exist" && exit -1

[[ ! -d /etc/init.d ]] && echo -e "${COLOR_RED}It appears that the init.d service does not exist.  Are you running ubuntu?" && exit -1

cp sacron_service /etc/init.d/sacron
chown root:root /etc/init.d/sacron
cp sacron.sh $BIN_DIR/sacron

cd sunwait-20041208
make
cp sunwait $BIN_DIR/sunwait

# create config
echo "BIN_DIR=$BIN_DIR" > /etc/sacron.conf

service sacron start
RESULT=$?
if [ $RESULT -eq 0 ]; then
  echo "couldn't start as normal service - starting directly"
  /etc/init.d/sacron start
fi