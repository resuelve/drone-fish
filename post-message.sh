#! /bin/bash

if [ ! -z ${GOOGLE_CHAT_URL} ]; then
	# this one is for 0.8 version
	WEBHOOK_URL=$GOOGLE_CHAT_URL
elif [ ! -z ${PLUGIN_WEBHOOK} ]; then
	# this one is for 1.X version
	WEBHOOK_URL=$PLUGIN_WEBHOOK
fi

if [ "${DRONE_BUILD_STATUS}" == 'failure' ]; then
	EVENT_MESS="Uh ..."
	EVENT_STATUS=https://raw.githubusercontent.com/resuelve/drone-fish/master/images/ups.png
else
	if [ "${DRONE_BUILD_EVENT}" == 'pull_request' ]; then
		EVENT_MESS="Por favor CR..."
		EVENT_STATUS=https://raw.githubusercontent.com/resuelve/drone-fish/master/images/please.png
    else
		EVENT_MESS="Listo ..."
		EVENT_STATUS=https://raw.githubusercontent.com/resuelve/drone-fish/master/images/success.png
	fi
fi

short_commit="${DRONE_COMMIT:0:8}"

case "$DRONE_BUILD_EVENT" in
  pull_request)
    event_ref="#$DRONE_PULL_REQUEST"
    event_link="$DRONE_REPO_LINK/pull/$DRONE_PULL_REQUEST"
  ;;
  tag)
    event_ref="$DRONE_TAG"
    event_link="$DRONE_REPO_LINK/releases/tag/$DRONE_TAG"
  ;;
  push)
    event_ref="$short_commit"
    event_link="$DRONE_REPO_LINK/commit/$DRONE_COMMIT"
  ;;
  promote)
    event_ref="build ${DRONE_BUILD_PARENT}"
  ;;
esac

data='{
  "cards": [
    {
      "header": {
        "title": "'"${DRONE_REPO}"'",
        "subtitle": "'"${DRONE_COMMIT_MESSAGE}"'"
      },
      "sections": [
        {
          "widgets": [
            {
              "keyValue": {
                "topLabel": "Build",
                "content": "'${DRONE_BUILD_NUMBER}'",
                "onClick": {
                  "openLink": {
                    "url": "'"${DRONE_BUILD_LINK}"'"
                  }
                }
              }
            },
            {
              "keyValue": {
                "topLabel": "Commit",
                "content": "'"${short_commit}"' by '"${DRONE_COMMIT_AUTHOR}"'"
              }
            },
            {
              "keyValue": {
                "topLabel": "Event",
                "content": "'"${DRONE_BUILD_EVENT}"' '"${event_ref}"'",
                "onClick": {
                  "openLink": {
                    "url": "'"${event_link:-$DRONE_BUILD_LINK}"'"
                  }
                }
              }
            }
          ]
        },
        {
          "header": "'"${EVENT_MESS}"'",
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
