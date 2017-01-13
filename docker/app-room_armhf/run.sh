docker stop raumklima
docker rm $(docker ps -q -f status=exited)
docker run --name raumklima -d -p 3838:3838 oydeu/app-room_armhf
