# Dockerfile
FROM node:0.10

MAINTAINER bharat@teamstitich.com

RUN groupadd -r rocketchat \
&&  useradd -r -g rocketchat rocketchat
RUN mkdir /home/rocketchat
RUN chown -R rocketchat /home/rocketchat

# gpg: key 4FD08014: public key "Team Stitch Buildmaster <bharat@teamstitch.com>" imported
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys 0E163286C20D07B9787EBE9FD7F9D0414FD08104

RUN mkdir /app
WORKDIR /app

# Copy the bundle from deploy folder to the contiainer
ADD ./.deploy/stitch-rocket.tar.gz .
ADD settings.json /app/settings.json

# Install node packges
WORKDIR /app/bundle/programs/server
RUN npm install

WORKDIR /app/bundle
USER rocketchat

RUN export METEOR_SETTINGS="$(cat /app/settings.json)"
#RUN rm /app/settings.json

ENV PORT 3000
EXPOSE 3000
CMD["node", "main.js"]
