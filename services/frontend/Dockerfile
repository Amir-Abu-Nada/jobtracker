FROM node:20-alpine

WORKDIR /app

# Copy package files
COPY package.json package-lock.json* ./

# Install dependencies
RUN npm install

# Copy source code
COPY . .

EXPOSE 5173

# Start Vite dev server with host binding (required for Docker)
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]
