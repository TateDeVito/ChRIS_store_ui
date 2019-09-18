#
# Docker file for ChRIS store ui production server
#
# Build with
#
#   docker build -t <name> .
#
# For example if building a local version, you could do:
#
#   docker build -t local/chris_store_ui .
#
# In the case of a proxy (located at say 10.41.13.4:3128), do:
#
#    export PROXY="http://10.41.13.4:3128"
#    docker build --build-arg http_proxy=${PROXY} --build-arg UID=$UID -t local/chris_store_ui .
#
# To run an interactive shell inside this container, do:
#
#   docker run -ti local/chris_store_ui sh
#
# To run the server up, do:
#
#   docker run --name chris_store_ui -p <port>:3000 -d local/chris_store_ui
#

FROM node:12-alpine
MAINTAINER fnndsc "dev@babymri.org"

# Pass a UID on build command line (see above) to set internal UID
ARG UID=1001
ENV UID=$UID  HOME="/home/localuser"  VERSION="0.1"

ENV APPROOT="${HOME}/build"

RUN adduser -u $UID -D localuser

COPY --chown=localuser ["./", "${HOME}"]

# build the app for production and install server
RUN su - localuser -c "yarn install && yarn build && yarn add serve --network-timeout 100000"

# Start as user localuser
USER localuser

WORKDIR $APPROOT
EXPOSE 3000

# serve the production build
CMD /home/localuser/node_modules/serve/bin/serve.js --single -l 3000 .
