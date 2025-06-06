#!/bin/sh

# Set environment variables for Next.js
export HOSTNAME=0.0.0.0
export PORT=3000

# Start Prisma Studio in the background
npx prisma studio --port 5556 --hostname 0.0.0.0 &

# Start the Next.js application
npm start 