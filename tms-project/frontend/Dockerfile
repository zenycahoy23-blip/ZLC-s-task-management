FROM node:22-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install --legacy-peer-deps --no-optional --legacy-bundling 2>&1 | grep -E "(added|removed|up to date|ERR)"

COPY . .

EXPOSE 3000

CMD ["npm", "run", "dev"]
