#!/bin/bash
set -e

#Integration test (Nginx + Redis)

#Getting initial and updated response from Nginx
initial=$(curl -s http://nginx/)
curl -s http://nginx/ > /dev/null
updated=$(curl -s http://nginx/)

#checking if updated response is different from initial
if [ "$initial" != "$updated" ]; then
    echo "Integration test passed"
    echo "Initial response: $initial"
    echo "Updated response: $updated"
else
    echo "Integration test failed"
    echo "Initial response: $initial"
    echo "Updated response: $updated"
    exit 1
fi
