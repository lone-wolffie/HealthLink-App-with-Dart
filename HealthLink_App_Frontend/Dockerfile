# Use a Flutter image that already has SDK installed
FROM cirrusci/flutter:latest

# Set working directory inside the container
WORKDIR /app

# Copy all project files into the container
COPY . .

# Build Flutter web release
RUN flutter build web --release

# Render expects static files in /public
RUN mkdir /public && cp -r build/web/* /public
