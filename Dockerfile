FROM cypress/base:14.17.0

USER root

RUN node --version

# Chrome dependencies
RUN apt-get update
RUN apt-get install -y fonts-liberation libappindicator3-1 xdg-utils

# install Chrome browser
ENV CHROME_VERSION 91.0.4472.114
RUN wget -O /usr/src/google-chrome-stable_current_amd64.deb "http://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_${CHROME_VERSION}-1_amd64.deb" && \
  dpkg -i /usr/src/google-chrome-stable_current_amd64.deb ; \
  apt-get install -f -y && \
  rm -f /usr/src/google-chrome-stable_current_amd64.deb
RUN google-chrome --version

# "fake" dbus address to prevent errors
# https://github.com/SeleniumHQ/docker-selenium/issues/87
ENV DBUS_SESSION_BUS_ADDRESS=/dev/null

# Add zip utility - it comes in very handy
RUN apt-get update && apt-get install -y zip


# versions of local tools
RUN echo  " node version:    $(node -v) \n" \
  "npm version:     $(npm -v) \n" \
  "yarn version:    $(yarn -v) \n" \
  "debian version:  $(cat /etc/debian_version) \n" \
  "Chrome version:  $(google-chrome --version) \n" \
  "git version:     $(git --version) \n" \
  "whoami:          $(whoami) \n"

# a few environment variables to make NPM installs easier
# good colors for most applications
ENV TERM xterm
# avoid million NPM install messages
ENV npm_config_loglevel warn
# allow installing when the main user is root
ENV npm_config_unsafe_perm true

FROM cypress/base:8 as e2eBuild

# Copy NPM & Install
COPY ./package.json /tmp/package.json
RUN cd /tmp && CI=true npm install
RUN CI=true /tmp/node_modules/.bin/cypress install
RUN CI=true /tmp/node_modules/.bin/playwright install
RUN mkdir -p /e2e && cp -a /tmp/node_modules /e2e/

WORKDIR /e2e
# Copy files for config
COPY ./cypress/cypress.json /e2e

# Run tests
CMD ["./node_modules/.bin/cypress", "run" ]