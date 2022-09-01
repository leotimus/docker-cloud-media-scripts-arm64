####################
# BASE IMAGE
####################
FROM arm64v8/ubuntu:22.04

####################
# INSTALLATIONS
####################
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y \
        curl \
        cron \
        fuse \
        unionfs-fuse \
        bc \
        unzip \
        wget \
        xz-utils \
        ca-certificates && \
    update-ca-certificates && \
    apt-get install -y openssl && \
    sed -i 's/#user_allow_other/user_allow_other/' /etc/fuse.conf

# S6 overlay
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2
ENV S6_KEEP_ENV=1
ADD https://github.com/just-containers/s6-overlay/releases/download/v3.1.2.1/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v3.1.2.1/s6-overlay-aarch64.tar.xz /tmp/
RUN tar -C / -Jxpf /tmp/s6-overlay-aarch64.tar.xz

####################
# ENVIRONMENT VARIABLES
####################
# Encryption
ENV ENCRYPT_MEDIA "1"
ENV READ_ONLY "1"

# Rclone
ENV BUFFER_SIZE "500M"
ENV MAX_READ_AHEAD "30G"
ENV CHECKERS "16"
ENV RCLONE_CLOUD_ENDPOINT "gd-crypt:"
ENV RCLONE_LOCAL_ENDPOINT "local-crypt:"

# Plexdrive
ENV CHUNK_SIZE "10M"
ENV CLEAR_CHUNK_MAX_SIZE ""
ENV CLEAR_CHUNK_AGE "24h"

# Time format
ENV DATE_FORMAT "+%F@%T"

# Local files removal
ENV REMOVE_LOCAL_FILES_BASED_ON "space"
ENV REMOVE_LOCAL_FILES_WHEN_SPACE_EXCEEDS_GB "100"
ENV FREEUP_ATLEAST_GB "80"
ENV REMOVE_LOCAL_FILES_AFTER_DAYS "30"

# Plex
ENV PLEX_URL ""
ENV PLEX_TOKEN ""

#cron
ENV CLOUDUPLOADTIME "0 1 * * *"
ENV RMDELETETIME "0 6 * * *"

####################
# SCRIPTS
####################
COPY setup/* /usr/bin/
COPY install.sh /
COPY scripts/* /usr/bin/
COPY root /

RUN chmod a+x /install.sh && \
    sh /install.sh && \
    chmod a+x /usr/bin/* && \
    groupmod -g 1000 users && \
	useradd -u 911 -U -d / -s /bin/false abc && \
	usermod -G users abc && \
    apt-get clean autoclean && \
    apt-get autoremove -y && \
    rm -rf /tmp/* /var/lib/{apt,dpkg,cache,log}/

RUN chmod a+x /etc/services.d/mount/run
RUN chmod a+x /etc/cont-finish.d/10-unmount-fuse

####################
# VOLUMES
####################
# Define mountable directories.
VOLUME /data/db /config /cloud-encrypt /cloud-decrypt /local-decrypt /local-media /chunks /log
# VOLUME /data/db /cloud-encrypt /cloud-decrypt /local-decrypt /local-media /chunks /log

RUN mkdir /data && mkdir /log && mkdir /config

RUN chmod -R 777 /data /log

####################
# WORKING DIRECTORY
####################
WORKDIR /data


####################
# ENTRYPOINT
####################
ENTRYPOINT ["/init"]
