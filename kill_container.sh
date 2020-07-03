DOCKER_ID=$(docker ps | grep linuxfromscratch |  head -n2 | tail -n 1| cut -f1 -d" ")
if [[ "${DOCKER_ID}" != "" ]]; then
    echo $DOCKER_ID;
    docker kill $DOCKER_ID
fi
