# kf
A small Kafka tool

## Install
wget -O kf https://raw.githubusercontent.com/RagingPuppies/kf/main/kf.sh;mv kf /usr/bin/;chmod 777 /usr/bin/kf

## Run 
Usage:
    kf -h                      Display this help message.
    kf <method> <option> <tag>
Example:
    kf.sh apply retention -t all -s A_kafka1 -r 300000000
    kf.sh get retention -t test -s A_kafka1
Methods:
    get, apply
Options:
    retention
Tags:
    -t <topic_name> \ All
    -s <bootstrap_server>
    -r <retention (int)>
