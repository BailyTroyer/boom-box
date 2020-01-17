FROM node:12.14.1

WORKDIR /usr/src/app

COPY . .

RUN npm install; npm run build

CMD ["npm", "run", "start"]

EXPOSE 3000