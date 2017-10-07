#! /bin/bash

log() {
  echo "$(date +"%D %T") $@"
}

error() {
  local parent_lineno="$1"
  local message="$2"
  local code="${3:-1}"
  if [[ -n "$message" ]] ; then
    log "Error on or near line ${parent_lineno}: ${message}; exiting with status ${code}"
  else
    log "Error on or near line ${parent_lineno}; exiting with status ${code}"
  fi
  exit "${code}"
}
trap 'error ${LINENO}' ERR

[[ -z "$BIN_DIR" ]] && BIN_DIR=/bin


source /etc/sacron.conf || log "no config file /etc/sacron.conf - using defaults"

declare -a scriptures=(
  "Remember the Sabbath day, to keep it holy. Exodus 20:8"
  "Six days shall work be done, but on the seventh day is a Sabbath of solemn rest, a holy convocation. You shall do no work. It is a Sabbath to the Lord in all your dwelling places. Leviticus 23:3"
  "So God blessed the seventh day and made it holy, because on it God rested from all his work that he had done in creation. Genesis 2:3"
)
RANDOM=$$$(date +%s)

get_lat_lon() {
  # get current latitude and longitude by IP
  IP=`curl -s ipinfo.io/ip`
  LOC=`curl -s ipinfo.io/$IP | grep 'loc' | awk '{ print $2 }'`

  # remove quotes and strip
  LOC=$(eval echo $LOC)

  IFS=',' read -ra ARR <<< "$LOC"
  LAT=${ARR[0]}
  LON=${ARR[1]}
}

if [[ -z "$LAT" || -z "$LON" ]]; then
  get_lat_lon
  log "Discovered latitude and longitude ${LAT}N, ${LON}E"
else
  log "Using configured latitude and longitude ${LAT}N, ${LON}E"
fi

check_sabbath() {
  if [[ "$TODAY" == "Sat" ]]; then
    log ${scriptures[$RANDOM % ${#scriptures[@]} ]}

    service cron stop

    # wait for sundown on Sunday
    sleep 30
    $BIN_DIR/sunwait -v -p sun down ${LAT}N ${LON}E

    log "Sabbath is over, time to start cron again"
    service cron start
  fi
}

while true
do
  TODAY=$(date '+%a')
  log "Today is $TODAY"

  $BIN_DIR/sunwait -v -p sun down ${LAT}N ${LON}E

  check_sabbath
done