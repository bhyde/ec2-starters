#!/bin/bash

. ../utilities/include-for-start-up.sh

begin_start_up rabbitmq

require erlang

LOG Configure apt: add http://www.rabbitmq.com/debian/ as an apt source, trust it, and then update apt.
cat <<'EOF' >> /etc/apt/sources.list
## The APT repository of rabbitmq.com
deb http://www.rabbitmq.com/debian/ testing main
EOF
curl -o /tmp/rabbitmq-signing-key-public.asc http://www.rabbitmq.com/rabbitmq-signing-key-public.asc
apt-key add /tmp/rabbitmq-signing-key-public.asc
rm /tmp/rabbitmq-signing-key-public.asc
apt-get update

LOG Install rabbitmq-server via apt
apt-get -y --force-yes install rabbitmq-server

LOG 'Stop rabbitmq, so it can be configured more approprately.'
invoke-rc.d rabbitmq-server stop

CONFIG=./rabbitmq-config.sh
if [ -s $CONFIG ] ; then
   $CONFIG
else
    ERROR "$CONFIG not found or not execuable in `pwd`"
fi

end_start_up rabbitmq
