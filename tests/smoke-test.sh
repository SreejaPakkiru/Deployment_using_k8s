#!/bin/bash

#Testing web1 service
if curl -s http://web1:5000 > /dev/null; then
  echo "web1 is up"
else
  echo "web1 is down"
  exit 1
fi

#Testing web2 service
if curl -s http://web2:5000 > /dev/null; then
  echo "web2 is up"
else
  echo "web2 is down"
  exit 1
fi
