FROM node:current-alpine3.23

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies (force + verbose for debugging)
RUN npm install --legacy-peer-deps --verbose --registry=https://registry.npmjs.org/

# Copy app files
COPY . .

EXPOSE 3000

CMD ["node", "index.js"]