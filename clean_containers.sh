#!/bin/bash

# docker rm all containers except for kind

docker rm -f $(docker ps -a | grep -v kind | grep -v CONTAINER | cut -f 1 -d ' ')
