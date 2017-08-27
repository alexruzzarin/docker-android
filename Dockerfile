FROM openjdk:8

MAINTAINER Alex Ruzzarin <alex@pager.com>

ENV DEBIAN_FRONTEND="noninteractive" && \
    TERM="dumb" && \
    VERSION_SDK_TOOLS="3859397" && \
    ANDROID_SDK_URL="https://dl.google.com/android/repository/sdk-tools-linux-${VERSION_SDK_TOOLS}.zip" && \
    ANDROID_HOME="/sdk" && \
    ANDROID_SDK="${ANDROID_HOME}" && \
    JAVA_OPTS="-Xms512m -Xmx1024m" && \
    GRADLE_OPTS="-XX:+UseG1GC -XX:MaxGCPauseMillis=1000" && \
    NPM_CONFIG_LOGLEVEL="info" && \
    PATH="${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools"

RUN apt-get -qq update && \
    apt-get install -qqy --no-install-recommends \
      html2text \
      libc6-i386 \
      lib32stdc++6 \
      lib32gcc1 \
      lib32ncurses5 \
      lib32z1 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -s https://dl.google.com/android/repository/sdk-tools-linux-${VERSION_SDK_TOOLS}.zip > /sdk.zip && \
    unzip /sdk.zip -d ${ANDROID_HOME} && \
    rm -v /sdk.zip

RUN mkdir -p $ANDROID_HOME/licenses/ && \
    echo "8933bad161af4178b1185d1a37fbf41ea5269c55" > $ANDROID_HOME/licenses/android-sdk-license && \
    echo "84831b9409646a918e30573bab4c9c91346d8abd" > $ANDROID_HOME/licenses/android-sdk-preview-license

ADD packages.txt /sdk
RUN mkdir -p /root/.android && \
  touch /root/.android/repositories.cfg && \
  ${ANDROID_HOME}/tools/bin/sdkmanager --update && \
  (while [ 1 ]; do sleep 5; echo y; done) | ${ANDROID_HOME}/tools/bin/sdkmanager --package_file=/sdk/packages.txt


RUN groupadd --gid 1000 node \
 && useradd --uid 1000 --gid node --shell /bin/bash --create-home node

RUN NODE_VERSION=$(curl -sL https://nodejs.org/download/release/index.tab | awk '(NR != 1) { print $1; exit}')
 && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" \
 && tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 \
 && rm "node-v$NODE_VERSION-linux-x64.tar.xz"