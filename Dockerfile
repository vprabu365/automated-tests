FROM node:10

COPY . .


#Installing all the dependencies needed by Playwright
RUN apt-get update &&\
    apt-get -y install libnss3 &&\
    apt-get -y install libasound2 &&\
    apt-get -y install libatspi2.0-0 &&\
    apt-get -y install libdrm2 &&\
    apt-get -y install libgbm1 && \
    apt-get -y install libgtk-3-0 && \
    apt-get -y install libxkbcommon-x11-0

RUN apt-get install -y wget &&\
    apt-get install -y libxss1 libappindicator1 libindicator7 &&\
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb &&\ 
    apt -y install ./google-chrome*.deb

RUN apt-get -y install libgtk2.0-0 libgtk-3-0 libgbm-dev libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2 libxtst6 xauth xvfb
# Move to the directory and install all the dependencies listed in Package.json
# RUN npm install playwright -save



# ---------------------------------------------------------------
# CI image
# - Used for Gitlab (see .gitlab-ci.yml)
# - MUST be updated whenever the CI installation requirements (i.e., packages/versions) change
# ---------------------------------------------------------------
# ARGS are declared before any FROM so that they are globally available
# Reference: https://github.com/docker/for-mac/issues/2155#issuecomment-372639972
ARG BASE_DOCKER_IMAGE
# ---------------------------------------------------------------
# Base image
# - Configure cache folders for npm and cypress
# - Install npm and cypress
# ---------------------------------------------------------------
FROM node:12 as base
# Args
ARG NODE_VERSION
ARG NPM_VERSION
ARG CYPRESS_VERSION
# Env
ENV NODE_VERSION="${NODE_VERSION}"
ENV NPM_VERSION="${NPM_VERSION}"
ENV NODE_ENV=development
ENV CYPRESS_VERSION="${CYPRESS_VERSION}"
# good colors for most applications
ENV TERM xterm
# avoid million NPM install messages
ENV npm_config_loglevel warn
# allow installing when the main user is root
ENV npm_config_unsafe_perm true
# avoid too many progress messages
ENV CI=1
# For cypress
# disable shared memory X11 affecting Cypress v4 and Chrome
# References:
# https://github.com/cypress-io/cypress-docker-images/blob/master/included/4.3.0/Dockerfile
# https://github.com/cypress-io/cypress-docker-images/issues/270
ENV QT_X11_NO_MITSHM=1
ENV _X11_NO_MITSHM=1
ENV _MITSHM=0
# Define the npm cache folder
ENV NPM_CACHE_FOLDER=/root/.cache/npm
# point Cypress at the /root/cache no matter what user account is used
# see https://on.cypress.io/caching
ENV CYPRESS_CACHE_FOLDER=/root/.cache/Cypress
RUN mkdir -p ~/.gnupg && \
  echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf && \
  # General packages
  apt-get update && \
  apt-get install -y --no-install-recommends bash curl gnupg dirmngr ca-certificates gnupg-agent software-properties-common apt-transport-https node-gyp python make g++ git && \
  # Cypress packages
  apt-get install -y --no-install-recommends libgtk2.0-0 libgtk-3-0 libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2 libxtst6 xauth xvfb && \
  # Docker packages
  curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" && \
  apt-get update && \
  apt-get install -y --no-install-recommends docker-ce docker-ce-cli containerd.io && \
  apt-get purge --auto-remove -y dirmngr gnupg ca-certificates && \
  rm -rf /var/lib/apt/lists/*
# Install npm & Cypress
RUN npm install --global npm@${NPM_VERSION} && \
  npm install -g "cypress@${CYPRESS_VERSION}" && \
  echo "Cypress configuration:" && \
  cypress cache path && \
  cypress cache list && \
  cypress info && \
  cypress verify
# Useful to inspect the image
#ENTRYPOINT ["/bin/bash"]
#CMD []
# ---------------------------------------------------------------
# Prefill npm cache image
# - Installs our dependencies so that the npm cache is "hot" in the image
# - We do not keep this image! It is only used to help construct the final image
# ---------------------------------------------------------------
FROM base as npm-install
RUN mkdir /temp
WORKDIR /temp
RUN echo "Work dir: $(pwd)"
COPY --chown=root:root package.json package-lock*.json ./
# Install npm dependencies
RUN npm ci --cache ${NPM_CACHE_FOLDER} --no-audit --no-optional
RUN echo "$(ls -ail ${NPM_CACHE_FOLDER})"
# Useful to inspect the image
#ENTRYPOINT ["/bin/bash"]
#CMD []
# ---------------------------------------------------------------
# Final CI image
# - Take the base image and add the npm cache to it (not the node modules of the project)
# ---------------------------------------------------------------
FROM base as ci
COPY --from=npm-install ${NPM_CACHE_FOLDER} ${NPM_CACHE_FOLDER}
RUN echo "$(ls -ail ${NPM_CACHE_FOLDER})"
# Useful to inspect the image
#ENTRYPOINT ["/bin/bash"]
#CMD []


# RUN $(npm bin)/cypress run --browser chrome

# FROM cypress/base:8.0.0
# # FROM cypress/base:12.4.0
# # FROM cypress/browsers:node12.6.0-chrome77
# #
# # FROM cypress/base:ubuntu19-node12.14.1

# RUN echo "current user: $(whoami)"
# RUN echo "current node: $(node -v)"
# RUN echo "current npm:  $(npm -v)"

# # avoid too many progress messages
# # https://github.com/cypress-io/cypress/issues/1243
# ENV CI=1
# # create package.json file
# # RUN npm init --yes

# # # install either a specific version of Cypress
# # ENV CYPRESS_INSTALL_BINARY=https://cdn.cypress.io/beta/binary/4.0.3/darwin-x64/circle-develop-cb0f32b0b4913cbb403f2e7c51b23ecad50ece9f-266831/cypress.zip
# # # RUN npm install --save-dev cypress@4.0.2
# # RUN npm install https://cdn.cypress.io/beta/npm/4.0.3/circle-develop-cb0f32b0b4913cbb403f2e7c51b23ecad50ece9f-266811/cypress.tgz
# # # or install a beta version of Cypress using environment variables
# # # ENV CYPRESS_INSTALL_BINARY=https://cdn.cypress.io/beta/binary/3.3.0/linux64/circle-develop-40502cbfb7b934afce0a7b1dba4141dab4adb202-100529/cypress.zip
# # # RUN npm install https://cdn.cypress.io/beta/npm/3.3.0/circle-develop-40502cbfb7b934afce0a7b1dba4141dab4adb202-100527/cypress.tgz

# # show where Cypress binary was installed
# # hmm, why silent exit?!
# RUN $(npm bin)/cypress cache path

# RUN ELECTRON_ENABLE_STACK_DUMPING=1 $(npm bin)/cypress verify
# # initialize a basic project with Cypress tests
# # RUN npx @bahmutov/cly init
# # if testing a base image with just Electron use "cypress run"
# RUN $(npm bin)/cypress run --browser chrome
# # # # if testing an image with Chrome browser
# # # RUN $(npm bin)/cypress run --browser chrome

