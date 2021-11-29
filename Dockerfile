FROM node:latest
RUN npm install -g http-server
RUN mkdir /public
WORKDIR /public

EXPOSE 8080
CMD ["http-server"]
