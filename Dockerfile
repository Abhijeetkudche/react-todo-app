# Stage 1: Build the React application
FROM node:20-alpine AS build

WORKDIR /app

# Copy package.json and package-lock.json first to leverage Docker cache
# This means npm install only re-runs if dependencies change
COPY package.json ./
COPY package-lock.json ./

RUN npm install

# Copy the rest of the application code
COPY . .

# Build the React app for production
# This creates the optimized static files in the 'build' directory
RUN npm run build

# Stage 2: Serve the React application with Nginx
FROM nginx:alpine AS production

# Copy the built React app from the 'build' stage to Nginx's static content directory
COPY --from=build /app/build /usr/share/nginx/html

# Copy a custom Nginx configuration to handle React routing (e.g., direct access to routes)
# We'll create this file next!
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80 for the Nginx web server
EXPOSE 80

# Command to run Nginx when the container starts
CMD ["nginx", "-g", "daemon off;"]