
set "DOCKER_DIR=~\Project\git"
set "UTIL=~"
set gx86="cpp-img"

set "CacheDir=ci_jenkins\.conan\data"

mkdir %CD%\%CacheDir%

docker ps -f name="x86-build-container" | find "Error" || docker stop x86-build-container && docker rm x86-build-container

docker create -it --name x86-build-container^
 --privileged^
 --network="host"^
 --cpuset-cpus=0-7^
 -v %CD%:/repo:delegated^
 -v %CD%\%CacheDir%:/home/ci_jenkins/.conan/data:delegated^
 --cap-add=ALL --cap-add=sys_nice --ulimit rtprio=99 --pid=host^
 %gx86%

  

docker start x86-build-container

::docker exec x86-build-container /bin/bash -c "cat /docker-util/in-docker-aliases-x86.sh >> ~/.bashrc "
docker exec -it x86-build-container /bin/bash



