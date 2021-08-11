FROM cypress/base:12.18.2

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


# avoid too many progress messages
ENV CI=1

# Move to the directory and install all the dependencies listed in Package.json
# RUN npm install playwright -save &&\ 
#     npm install cypress -save 


# RUN $(npm bin)/cypress run --browser chrome
RUN CYPRESS_CACHE_FOLDER=~/.cache/Cypress npm install playwright -save

RUN CYPRESS_CACHE_FOLDER=~/.cache/Cypress npm install cypress -save

# RUN $(npm bin)/cypress verify


# RUN npm install --save-dev cypress

# RUN $(npm bin)/cypress run
