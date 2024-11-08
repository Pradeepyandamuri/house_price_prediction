# Step 1: Set up Python environment for backend
FROM python:3.9-slim as python_base

# Set working directory
WORKDIR /app

# Copy the server code and requirements.txt
COPY server/requirements.txt /app/
RUN pip install -r requirements.txt

# Copy the server.py and util.py
COPY server /app

# Step 2: Set up Nginx for frontend
FROM nginx:alpine as nginx_base

# Copy the Nginx config file for reverse proxy
COPY nginx_file/bhp.conf /etc/nginx/nginx.conf

# Copy client-side static files to Nginx directory
COPY client /usr/share/nginx/html

# Expose necessary ports
EXPOSE 80
EXPOSE 5000

# Step 3: Set up the final container with both Flask and Nginx
FROM python_base

# Copy Nginx setup from nginx_base
COPY --from=nginx_base /etc/nginx/nginx.conf /etc/nginx/nginx.conf
COPY --from=nginx_base /usr/share/nginx/html /usr/share/nginx/html

# Run the Flask app and Nginx simultaneously
CMD ["sh", "-c", "nginx -g 'daemon off;' & python /app/server.py"]
