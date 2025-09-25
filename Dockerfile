# Use Node 16 as base
FROM node:16

# Set working directory
WORKDIR /app

# Copy dependency definitions
COPY package*.json ./

# Install dependencies
RUN npm install --production

# Copy application source
COPY . .

# Expose port used by app
EXPOSE 3000

# Command to run the app
CMD ["node", "app.js"]
