function active_task {
    /usr/local/bin/kafka-cluster-manager \
    --cluster-type generic \
    --cluster-name this_cluster \
    stats >/dev/null 2>/dev/null
    trigger=$?

    if [[ $trigger -ne 0 ]]; then
        return 0
    else
        return 1
    fi
}

function validate_args {
    if [ ! "$1" = "" ] 
    then
      return
    else
      echo "Missing argument, Broker_ID, Exiting."
      exit 1
    fi
}


function progress_bar {
    total=$1 
    current=$2 
    process=$3
    meta="$process: $1 / $2"
    precent=$(expr $current \* 100 / $total)
    hashes=$(expr $precent / 2)
    spaces=$(expr 50 - $hashes)
    hashtag=""
    space=""
    for i in $(seq 1 $hashes)
    do
        hashtag="#$hashtag"
    done

    for i in $(seq 1 $spaces)
    do
        space=" $space"
    done

    if [ $precent -eq 100 ]
    then
        space=""
    fi

    echo -ne "$meta |$hashtag$space|($precent%)\r"
}


function checkStatus {
  expect=250
  if [ $# -eq 3 ] ; then
    expect="${3}"
  fi
  if [ $1 -ne $expect ] ; then
    echo "Error: ${2}"
    exit
  fi
}

function sendMail {
    Subject=$1
    Message=$2
    User=$3
    MyHost='domain.com'

    MailHost="smtp"
    MailPort=25

    FromAddr="kf-tool@domain.com"

    ToAddr="${User}@domain.com"

    if [[ "$VR_CONFIGURATION" == "production" && $(ping $MailHost ; echo "$?") == "0" ]]
    then
      exec 3<>/dev/tcp/${MailHost}/${MailPort}

      read -u 3 sts line
      checkStatus "${sts}" "${line}" 220

      echo "HELO ${MyHost}" >&3

      read -u 3 sts line
      checkStatus "$sts" "$line"

      echo "MAIL FROM: ${FromAddr}" >&3

      read -u 3 sts line
      checkStatus "$sts" "$line"

      echo "RCPT TO: ${ToAddr}" >&3

      read -u 3 sts line
      checkStatus "$sts" "$line"

      echo "DATA" >&3

      read -u 3 sts line
      checkStatus "$sts" "$line" 354
      echo "From: ${FromAddr}" >&3
      echo "To: ${ToAddr}" >&3
      echo "Subject: ${Subject}" >&3
      echo "${Message}" >&3
      echo "." >&3

      read -u 3 sts line
      checkStatus "$sts" "$line"

    else
        echo "TEST MODE: Sending email to ${ToAddr}"
    fi
}

function sendCL {
    Operation=$1
    Username=$2
    RavenAPI='domain.com:8080/Raven/api/sendEvent'
    data='{"owner":"datainfra","type":"changelog","origin":"kf_tool","map":{"service":"kf_tool", "username":"'${Username}'"},"message":"Starting '${Operation}'."}'
    if [[ "$VR_CONFIGURATION" == "production" ]]
    then
        curl -X PUT -H "Content-Type: application/json" -d "$data" "$RavenAPI"
    else
        echo "TEST MODE: Sending CL, data: ${data} to: ${RavenAPI}"
    fi
    

}
