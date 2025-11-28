FROM ghcr.io/cirruslabs/flutter:3.22.2  

WORKDIR /app
COPY . .

RUN flutter build web --release

# Render expects static files in /public
RUN mkdir /public && cp -r build/web/* /public
