# Use Node.js 18 Alpine as base image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install all dependencies (including dev dependencies for build)
RUN npm ci

# Copy source code
COPY . .

# Copy Prisma directory
COPY prisma ./prisma

# Copy startup script
COPY start.sh ./start.sh

# Make startup script executable
RUN chmod +x ./start.sh

# Generate Prisma client
RUN npx prisma generate

# Build the application
RUN npm run build

# Expose ports for Next.js app and Prisma Studio
EXPOSE 3000 5556

# Use startup script as entry point
CMD ["./start.sh"] 