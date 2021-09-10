FROM node:16

ADD . /opt
RUN chmod +x /opt/Docker-entrypoint.sh
WORKDIR /opt
RUN npm install nodemon -g
# RUN npm install yarn -g
RUN yarn
EXPOSE 5000

ENTRYPOINT ["/opt/Docker-entrypoint.sh"]
CMD [ "npm", "run", "server" ]