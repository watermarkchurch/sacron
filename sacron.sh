#! /bin/bash


log() {
  echo "$(date +"%D %T") $@"
}

declare -a scriptures=(
  "Remember the Sabbath day, to keep it holy. Exodus 20:8"
  "Six days shall work be done, but on the seventh day is a Sabbath of solemn rest, a holy convocation. You shall do no work. It is a Sabbath to the Lord in all your dwelling places. Leviticus 23:3"
  "So God blessed the seventh day and made it holy, because on it God rested from all his work that he had done in creation. Genesis 2:3"
)
RANDOM=$$$(date +%s)

# get current latitude and longitude by IP
IP=`curl -s ipinfo.io/ip`
LOC=`curl -s ipinfo.io/$IP | grep 'loc' | awk '{ print $2 }'`

# remove quotes and strip
LOC=$(eval echo $LOC)

IFS=',' read -ra ARR <<< "$LOC"
LAT=${ARR[0]}
LON=${ARR[1]}

check_sabbath() {
  if [[ "$TODAY" == "Thu" ]]; then
    log ${scriptures[$RANDOM % ${#scriptures[@]} ]}

    service cron stop

    # wait for sundown on Sunday
    sleep 30
    sunwait-20041208/sunwait -v -p sun down ${LAT}N ${LON}E

    log "Sabbath is over, time to start cron again"
    service cron start
  fi
}

while true
do
  TODAY=$(date '+%a')
  log "Today is $TODAY"

  # sunwait-20041208/sunwait -v -p sun down ${LAT}N ${LON}E

  check_sabbath
done