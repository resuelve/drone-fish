#! /bin/bash

if [ ! -z ${GOOGLE_CHAT_URL} ]; then
	# this one is for 0.8 version
	WEBHOOK_URL=$GOOGLE_CHAT_URL
elif [ ! -z ${PLUGIN_WEBHOOK} ]; then
	# this one is for 1.X version
	WEBHOOK_URL=$PLUGIN_WEBHOOK
fi

images_url="https://raw.githubusercontent.com/resuelve/drone-fish/master/images"

if [ "${DRONE_BUILD_STATUS}" == 'failure' ]; then
	EVENT_MESS="Uh ..."
	EVENT_STATUS="$images_url/ups.png"
else
	if [ "${DRONE_BUILD_EVENT}" == 'pull_request' ]; then
		EVENT_MESS="Por favor CR..."
		EVENT_STATUS="$images_url/please.png"
    else
		EVENT_MESS="Listo ..."
		EVENT_STATUS="$images_url/success.png"
	fi
fi

short_commit="${DRONE_COMMIT:0:8}"
commit_link="$DRONE_REPO_LINK/commit/$DRONE_COMMIT"

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
    event_link="$commit_link"
  ;;
  promote)
    event_ref="build ${DRONE_BUILD_PARENT}"
  ;;
esac

data=$(jq -n \
  --arg title "$DRONE_REPO" \
  --arg subtitle "$DRONE_COMMIT_MESSAGE" \
  --arg status_icon "$images_url/status_$DRONE_BUILD_STATUS.png" \
  --arg build_number "$DRONE_BUILD_NUMBER" \
  --arg build_link "$DRONE_BUILD_LINK" \
  --arg commit_text "$short_commit by $DRONE_COMMIT_AUTHOR" \
  --arg commit_link "$commit_link" \
  --arg event_text "$DRONE_BUILD_EVENT $event_ref" \
  --arg event_link "${event_link:-$DRONE_BUILD_LINK}" \
  --arg ryc_msg "$EVENT_MESS" \
  --arg ryc_img "$EVENT_STATUS" \
'{
  "cards": [
    {
      "header": {
        "title": $title,
        "subtitle": $subtitle,
        "imageUrl": $status_icon
      },
      "sections": [
        {
          "widgets": [
            {
              "keyValue": {
                "topLabel": "Build",
                "content": $build_number,
                "onClick": {
                  "openLink": {
                    "url": $build_link
                  }
                }
              }
            },
            {
              "keyValue": {
                "topLabel": "Commit",
                "content": $commit_text,
                "onClick": {
                  "openLink": {
                    "url": $commit_link
                  }
                }
              }
            },
            {
              "keyValue": {
                "topLabel": "Event",
                "content": $event_text,
                "onClick": {
                  "openLink": {
                    "url": $event_link
                  }
                }
              }
            }
          ]
        },
        {
          "header": $ryc_msg,
       	  "widgets": [
            {
              "image": {
                "imageUrl": $ryc_img
              }
            }
          ]
        }
      ]
    }
  ]
}')

curl \
	-H "Content-Type: aplication/json" \
	-X POST -d "$data" \
	"${WEBHOOK_URL}"
