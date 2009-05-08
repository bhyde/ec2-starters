#!/bin/bash

if [ -x rabbitmq-config.sh ] ; then
  echo "checking rabbitmq-config.sh exists, ok"
  if grep -si example rabbitmq-config.sh ; then
    echo "please remove the word example entirely from rabbitmq-config.sh"
    exit 1
  fi
  exit 0
else
  echo "missing or not executable rabbitmq-config.sh, copy and edit rabbitmq-config.sh-example"
  exit 1
fi
