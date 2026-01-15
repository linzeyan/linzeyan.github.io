FROM --platform=$TARGETPLATFORM emqx:5.7.1

COPY --chown=emqx:emqx acl.conf /opt/emqx/etc/acl.conf
COPY --chown=emqx:emqx emqx.conf /opt/emqx/etc/emqx.conf
COPY --chown=emqx:emqx bootstrap /opt/emqx/etc/bootstrap

# docker buildx build --push --platform linux/arm64,linux/amd64 -t 891377177527.dkr.ecr.ap-northeast-1.amazonaws.com/base-images:emqx-5.7.0 -t 891377177527.dkr.ecr.ap-northeast-1.amazonaws.com/base-images:emqx-latest .