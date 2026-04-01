# Use stable Node.js Alpine image
FROM node:20-alpine

# Set working directory
WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install --legacy-peer-deps --verbose

# Copy rest of app
COPY . .

# Expose app port
EXPOSE 3000

# Start the app
CMD ["node", "index.js"]