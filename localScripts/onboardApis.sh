#! /bin/bash

HOSTNAME='gas.stsvp1eic28.stsoss.sero.gic.ericsson.se'
USERNAME='gas-user'
PASSWORD='idunEr!css0n'
PREFIX='/sample-pme-client'
DEPLOYMENT='eric-oss-sample-pme-client'
JSESSIONID=''

function readArgs(){
  while getopts "h:u:p:d:i:" flag
  do
    case "${flag}" in
      h) HOSTNAME=${OPTARG};;
      u) USERNAME=${OPTARG};;
      p) PASSWORD=${OPTARG};;
      d) DEPLOYMENT=${OPTARG};;
      i) PREFIX=${OPTARG};;
      *)
        log "Usage: $0 [-h hostname] [-u user] [-p password] [-d deployment] [-i ingress_prefix]"
        exit 1
        ;;
    esac
  done
}

function log() {
  echo -e "\n$(date) --- ${1} \n"
}

function checkExitCode() {
    if [ $? -ne 0 ]; then
          log "ERROR: $1 "
          exit 255
    fi
}

function getSessionId() {
  JSESSIONID=$(
    curl -sk --location --request POST "https://${HOSTNAME}/auth/v1/login" \
    --header "X-Login: ${USERNAME}" \
    --header "X-password: ${PASSWORD}"
  )

  checkExitCode "Failed to get JSESSIONID"

  log "JSESSIONID: ${JSESSIONID}"
}

function onboardApi() {
  log "Onboarding API '${DEPLOYMENT}' for '${PREFIX}'"

  status_code=$(curl -ks -w '%{response_code}' --location "https://${HOSTNAME}/v1/routes/${DEPLOYMENT}" \
    --cookie "JSESSIONID=${JSESSIONID}" \
    -o /tmp/response_body.txt)

  verb='POST'

  if [[ "${status_code}" -eq '200' ]] ; then
    log "Route already exists, updating route"
    verb='PUT'
  fi

  status_code=$(curl -ks -w '%{response_code}' -X "${verb}" --location "https://${HOSTNAME}/v1/routes" \
  --cookie "JSESSIONID=${JSESSIONID}" \
  --header 'Content-Type: application/json' \
  -o /tmp/response_body.txt \
  --data "{
           \"id\": \"${DEPLOYMENT}\",
           \"predicates\": [
             {
               \"name\": \"Path\",
               \"args\": {
                 \"_genkey_0\":\"${PREFIX}/*/sessions\",
                 \"_genkey_1\": \"${PREFIX}/*/verdicts\"
               }
             },
             {
               \"name\": \"Host\",
               \"args\": {
                 \"_genkey_0\": \"${HOSTNAME}\"
               }
             }
           ],
           \"filters\": [
             {
               \"name\": \"RewritePath\",
               \"args\": {
                 \"_genkey_0\": \"${PREFIX}/(?<segment>.*)\",
                 \"_genkey_1\": \"/$\\\\{segment}\"
               }
             }
           ],
           \"uri\": \"http://${DEPLOYMENT}:8080\",
           \"order\": 0
         }")

  echo "Status code of onboarding API :: ${status_code}"

  if [[ "${status_code}" -ne '201' ]] && [[ "${status_code}" -ne '200' ]] ; then
    echo "Failed to onboard API. Status code:: ${status_code}"
    echo "Response body:"
    cat /tmp/response_body.txt
    echo
    rm /tmp/response_body.txt
    exit 1
  fi

  log "Onboarded API successfully"
}

#########
# main
#########

readArgs $@

echo "Running with: HOSTNAME (-h):" $HOSTNAME ", USER (-u):" $USERNAME ", PASSWORD (-p):" $PASSWORD ", DEPLOYMENT (-d):" $DEPLOYMENT ", PREFIX: " $PREFIX

getSessionId
onboardApi