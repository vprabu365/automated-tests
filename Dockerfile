
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


# ENV npm_config_loglevel warn
# # # allow installing when the main user is root
# ENV npm_config_unsafe_perm true
# # # avoid too many progress messages
# ENV CI=1
# Move to the directory and install all the dependencies listed in Package.json
# RUN npm install playwright -save
RUN npm install
# RUN npm install cypress  -save

RUN npm run test
# RUN $(npm bin)/cypress run --browser chrome

# ENV NPM_CACHE_FOLDER=/root/.cache/npm

# ENV CYPRESS_CACHE_FOLDER=./root/.cache/Cypress