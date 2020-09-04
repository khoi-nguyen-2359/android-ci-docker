FROM ubuntu:18.04

LABEL maintainer "akhoi90@gmail"

WORKDIR /

SHELL ["/bin/bash", "-c"]

ARG GRADLE_VERSION=6.1.1
ARG ANDROID_COMPILE_SDK=30
ARG ANDROID_EMU_IMAGE=22
ARG ANDROID_BUILD_TOOLS=30.0.1
ARG ANDROID_CMD_TOOLS=6609375_latest

# Path & Compatibility
ENV GRADLE_HOME "/opt/gradle/gradle-$GRADLE_VERSION"
ENV ANDROID_HOME "/opt/android"
ENV ANDROID_SDK_ROOT "/opt/android"

RUN DEBIAN_FRONTEND=noninteractive \
TZ=Asia/Saigon \
apt update && apt install -y openjdk-8-jdk nano git unzip libglu1 libpulse-dev libasound2 libc6  libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxi6  libxtst6 libnss3 wget

# Gradle
RUN wget https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -P /tmp \
&& unzip -d /opt/gradle /tmp/gradle-${GRADLE_VERSION}-bin.zip \
&& mkdir /opt/gradlew \
&& /opt/gradle/gradle-${GRADLE_VERSION}/bin/gradle wrapper --gradle-version ${GRADLE_VERSION} --distribution-type all -p /opt/gradlew  \
&& /opt/gradle/gradle-${GRADLE_VERSION}/bin/gradle wrapper -p /opt/gradlew

# Android SDK
RUN wget "https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_CMD_TOOLS}.zip" -P /tmp \
&& mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools \
&& unzip -d /opt/android/cmdline-tools /tmp/commandlinetools-linux-${ANDROID_CMD_TOOLS}.zip \
&& yes Y | /opt/android/cmdline-tools/tools/bin/sdkmanager --install "platform-tools" "system-images;android-${ANDROID_EMU_IMAGE};google_apis;armeabi-v7a" "platforms;android-${ANDROID_COMPILE_SDK}" "build-tools;${ANDROID_BUILD_TOOLS}" "emulator" \
&& yes Y | /opt/android/cmdline-tools/tools/bin/sdkmanager --licenses \
&& echo "no" | /opt/android/cmdline-tools/tools/bin/avdmanager --verbose create avd --force --name "test" --package "system-images;android-${ANDROID_EMU_IMAGE};google_apis;armeabi-v7a"

ENV PATH "$PATH:$GRADLE_HOME/bin:/opt/gradlew:$ANDROID_HOME/emulator:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools"
ENV LD_LIBRARY_PATH "$ANDROID_HOME/emulator/lib64:$ANDROID_HOME/emulator/lib64/qt/lib"

ADD start.sh /
RUN chmod +x start.sh