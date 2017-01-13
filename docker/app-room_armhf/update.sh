#!/bin/bash

if [ $# -eq 0 ]
  then
    docker build -t oydeu/app-room_armhf .
  else
    docker build --no-cache -t oydeu/app-room_armhf .
fi
docker push oydeu/app-room_armhf
