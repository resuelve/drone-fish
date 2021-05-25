#! /bin/bash

if [ ! -z ${GOOGLE_CHAT_URL} ]; then
	# this one is for 0.8 version
	WEBHOOK_URL=$GOOGLE_CHAT_URL
elif [ ! -z ${PLUGIN_WEBHOOK} ]; then
	# this one is for 1.X version
	WEBHOOK_URL=$PLUGIN_WEBHOOK
fi

if [ "${DRONE_BUILD_STATUS}" == 'failure' ]; then
	EVENT_MESS="*Uh ...*"
	EVENT_STATUS=https://raw.githubusercontent.com/resuelve/drone-fish/master/images/ups.png
else
	if [ "${DRONE_BUILD_EVENT}" == 'pull_request' ]; then
		EVENT_MESS="*Por favor CR...*"
		EVENT_STATUS=https://raw.githubusercontent.com/resuelve/drone-fish/master/images/please.png
    else
		EVENT_MESS="*Listo ...*"
		EVENT_STATUS=https://raw.githubusercontent.com/resuelve/drone-fish/master/images/success.png
	fi
fi

data='{
  "text":" *Drone:* '"${DRONE_REPO}"' '"${DRONE_BUILD_LINK}"'
  *Commit:* '"${DRONE_COMMIT_REF}"': '"${DRONE_COMMIT_MESSAGE}"'
  *Author:* '"${DRONE_COMMIT_AUTHOR}"'
  *Event #:* '"${DRONE_BUILD_NUMBER}"': '"${DRONE_BUILD_EVENT}"'
  '"${EVENT_MESS}"'",
  "cards": [
    {
      "sections": [
        {
       	  "widgets": [
            {
              "image": {
                "imageUrl": "'"${EVENT_STATUS}"'"
              }
            }
          ]
        }
      ]
    }
  ]
}'

curl \
	-H "Content-Type: aplication/json" \
	-X POST -d "$data" \
	"${WEBHOOK_URL}"
