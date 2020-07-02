docker kill $(docker ps | grep linuxfromscratch |  head -n2 | tail -n 1| cut -f1 -d" ")
