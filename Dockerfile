FROM node:14.21.2
WORKDIR /usr/src/backend/app

COPY package.json .
RUN npm install
RUN npm install -g nodemon
COPY . .

EXPOSE 6200
CMD [ "npm", "start" ]