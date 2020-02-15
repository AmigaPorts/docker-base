# docker-aros-build

Build the base image for every Amiga-flavoured cross toolchain.

Currently the image is based on Debian.

### Build the Docker container

docker build -t "amigadev/docker-base" --rm -f Dockerfile .
