FROM node:latest AS base

#### Stage BUILD #######################################################################################################
FROM base AS build

FROM dustynv/jetson-inference:r32.7.1

# ARG APT_PROXY
# COPY docker/detect-apt-proxy.sh /root
# RUN  echo "apt proxy: ${APT_PROXY}"
# RUN /root/detect-apt-proxy.sh ${APT_PROXY}


ENV TZ="Asia/Taipei"
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
# Install tools, create Node-RED app and data dir, add user and set rights
RUN set -ex && \
    apt-get update && apt-get install -yq --no-install-recommends \
        bash \
        tzdata \
        curl \
        nano \
        wget \
        git \
        openssl \
        openssh-client \
        libzmq3-dev  \
        ca-certificates && \
	# ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime && \
	# dpkg-reconfigure -f noninteractive tzdata \
    mkdir -p /usr/src/node-red /data && \
    # deluser --remove-home node && \
    # adduser --home /usr/src/node-red --disabled-password --no-create-home node-red --uid 1000 && \
    useradd --home-dir /usr/src/node-red --uid 1000 node-red && \
    chown -R node-red:root /data && chmod -R g+rwX /data && \
    chown -R node-red:root /usr/src/node-red && chmod -R g+rwX /usr/src/node-red
    # chown -R node-red:node-red /data && \
    # chown -R node-red:node-red /usr/src/node-red

#Install python package
RUN pip3 install imagezmq

# Install Build tools
RUN curl -fsSL https://deb.nodesource.com/setup_14.x | bash -
RUN apt-get install -yq --no-install-recommends nodejs

# RUN  npm --registry https://registry.npm.taobao.org install -g --unsafe-perm node-red

# RUN npm --registry https://registry.npm.taobao.org install --unsafe-perm --no-update-notifier --no-fund --only=production && \
#     npm uninstall node-red-node-gpio && \
#     cp -R node_modules prod_node_modules


# Set work directory
WORKDIR /usr/src/node-red

# Setup SSH known_hosts file
COPY docker/known_hosts.sh .
RUN ls
RUN  ./known_hosts.sh /etc/ssh/ssh_known_hosts 
# RUN rm /usr/src/node-red/known_hosts.sh

# package.json contains Node-RED NPM module and node dependencies
COPY docker/package.json .
COPY docker/flows.json /data


#### Stage RELEASE #####################################################################################################
ARG RELEASE
ARG BUILD_DATE
ARG BUILD_VERSION
ARG BUILD_REF
ARG NODE_RED_VERSION
ARG ARCH
ARG TAG_SUFFIX=default

LABEL org.label-schema.build-date=${BUILD_DATE} \
    org.label-schema.docker.dockerfile="Dockerfile" \
    org.label-schema.license="Apache-2.0" \
    org.label-schema.name="Node-RED" \
    org.label-schema.version=${BUILD_VERSION} \
    org.label-schema.description="Low-code programming for event-driven applications." \
    org.label-schema.url="https://nodered.org" \
    org.label-schema.vcs-ref=${BUILD_REF} \
    org.label-schema.vcs-type="Git" \
    org.label-schema.vcs-url="https://github.com/node-red/node-red-docker" \
    org.label-schema.arch=${ARCH} \
    authors="Dave Conway-Jones, Nick O'Leary, James Thomas, Raymond Mouthaan"

# COPY --from=build /usr/src/node-red/prod_node_modules ./node_modules




# Chown, install devtools & Clean up
# RUN chown -R node-red:root /usr/src/node-red && \
#     rm -r /tmp/*

# USER node-red

# Env variables
ENV NODE_RED_VERSION=$NODE_RED_VERSION \
    NODE_PATH=/usr/src/node-red/node_modules:/data/node_modules \
    PATH=/usr/src/node-red/node_modules/.bin:${PATH} \
    FLOWS=docker/flows.json

# ENV NODE_RED_ENABLE_SAFE_MODE=true    # Uncomment to enable safe start mode (flows not running)
# ENV NODE_RED_ENABLE_PROJECTS=true     # Uncomment to enable projects option

# Expose the listening port of node-red
EXPOSE 1880

# Add a healthcheck (default every 30 secs)
# HEALTHCHECK CMD curl http://localhost:1880/ || exit 1

# ENTRYPOINT ["node-red", "--cache", "/data/.npm", "--", "--userDir", "/data"]