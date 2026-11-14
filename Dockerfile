FROM node:18-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY func.js, change.html, create.html, list.html, look.html, menu.html, style.css

EXPOSE 3000

CMD ["node", "script.js"]