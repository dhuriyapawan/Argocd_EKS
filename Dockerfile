FROM node:20-alpine3.19

WORKDIR /app

# Copy only package.json (NOT package-lock.json initially)
COPY package.json ./

# Clean install (no lock file issues)
RUN npm install --verbose

# Copy rest of files
COPY . .

EXPOSE 3000

CMD ["node", "index.js"]