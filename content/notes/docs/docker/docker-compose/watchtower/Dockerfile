# Final image has to be alpine, scratch doesn't support our env vars or credentials file
FROM alpine:3.20
# LABEL "com.centurylinklabs.watchtower"="true"

COPY --from=containrrr/watchtower:1.7.1 / /
# https://github.com/awslabs/amazon-ecr-credential-helper#installing
# hadolint ignore=DL3018
RUN apk add --no-cache docker-credential-ecr-login && echo '{"credsStore": "ecr-login"}' >/config.json
EXPOSE 8080
HEALTHCHECK CMD [ "/watchtower", "--health-check"]
ENTRYPOINT ["/watchtower"]

# docker buildx create --use
# docker buildx build --push --platform linux/arm64,linux/amd64 -t zeyanlin/watchtower -t zeyanlin/watchtower:v1.0.0 .