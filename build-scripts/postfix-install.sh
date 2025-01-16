#!/bin/sh
set -e

if [ -f /etc/os-release ]; then
    . /etc/os-release
fi

do_alpine() {
    apk update
    apk add --upgrade cyrus-sasl cyrus-sasl-static cyrus-sasl-digestmd5 cyrus-sasl-crammd5 cyrus-sasl-login cyrus-sasl-ntlm libsasl
    apk add postfix postfix-pcre postfix-ldap
    apk add opendkim
    apk add --upgrade ca-certificates tzdata supervisor rsyslog musl musl-utils bash opendkim-utils libcurl jsoncpp lmdb logrotate netcat-openbsd
}


do_ubuntu() {
    RELEASE_SPECIFIC_PACKAGES=""
    export DEBCONF_NOWARNINGS=yes
    export DEBIAN_FRONTEND=noninteractive
    echo "Europe/Berlin" > /etc/timezone
    apt-get update -y -q
    apt-get install -y libsasl2-modules sasl2-bin
    apt-get install -y postfix postfix-pcre postfix-ldap
    apt-get install -y opendkim
    apt-get install -y ca-certificates tzdata supervisor rsyslog bash opendkim-tools curl libcurl4 libjsoncpp25 sasl2-bin postfix-lmdb procps logrotate cron net-tools colorized-logs netcat-openbsd ${RELEASE_SPECIFIC_PACKAGES}
    apt-get clean
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*    
}

if [ -f /etc/alpine-release ]; then
    do_alpine
else
    do_ubuntu
fi

# Some services (eg. cron) will complain if this file does not exists, even if it's empty
# The file is usually generated by update-locales, which is ran automatically when you do
# `apt-get install locales`. So instead of adding another package, which at the moment we
# do not need, we just create a simple "empty" file instead and hope to keep cron happy.
mkdir -p /etc/default/
echo "#  File generated by postfix-install.sh" > /etc/default/locale

cp -r /etc/postfix /etc/postfix.template
