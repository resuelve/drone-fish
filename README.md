# Drone plugin to send an alert to google chat

It sends a message to Google chat channel with the result of the build, the result will be presented as a card.

## Usage

For version `0.8`

```yaml
notify:
  image: resuelve/drone-fish
  secrets: [ google_chat_url ]
  when:
    status: [ success, failure ]
```

For version `1.X`

```yaml
notify:
  image: resuelve/drone-fish
  settings:
    webhook:
      from_secret: webhook_url
  when:
    status: [ success, failure ]
```
