#!/bin/bash

# To prevent the logs from logstash itself from spamming filebeat, we re-direct
# the stdout from logstash to /dev/null here. If you need to see the output from
# logstash when debugging, remove this re-direct.
logstash > /dev/null
