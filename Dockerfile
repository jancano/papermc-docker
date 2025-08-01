# We're no longer using openjdk:17-slim as a base due to several unpatched vulnerabilities.
# The results from basing off of alpine are a smaller (by 47%) and faster (by 17%) image.
# Even with bash installed.     -Corbe
FROM alpine:latest

# Environment variables
ENV MC_VERSION="1.21.8" \
    PAPER_BUILD="latest" \
    EULA="true" \
    MC_RAM="" \
    JAVA_OPTS=""

COPY papermc.sh .
RUN apk update \
    && apk upgrade  \
    && apk add --upgrade apk-tools  \
    && apk add build-base \
    && apk add libstdc++ \
    && apk add openjdk21-jre \
    && apk add bash \
    && apk add wget \
    && apk add curl \
    && apk add jq \
    && apk add --no-cache udev \
    && mkdir /papermc

# Start script
CMD ["bash", "./papermc.sh"]

# Container setup
EXPOSE 25565/tcp
EXPOSE 25565/udp
VOLUME /papermc
