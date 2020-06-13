FROM alpine:3.4
RUN apk --no-cache add curl ca-certificates bash
COPY post-message.sh /bin/
ENTRYPOINT ["/bin/bash"]
CMD ["/bin/post-message.sh"]
