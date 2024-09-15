FROM nginx:1.18

# Install necessary packages (Node.js, Git, Curl, etc.)
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get update -y && \
    apt-get install -y git curl nodejs && \
    curl -sL https://github.com/gohugoio/hugo/releases/download/v0.72.0/hugo_extended_0.72.0_Linux-64bit.tar.gz | \
    tar -xz hugo && mv hugo /usr/bin && \
    npm i -g postcss-cli autoprefixer postcss

# Clone the repository containing the Hugo site
RUN git clone https://github.com/MicrosoftDocs/mslearn-aks-deployment-pipeline-github-actions /contoso-website

# Set working directory to the project folder
WORKDIR /contoso-website/src

# Initialize the Hugo theme submodule
RUN git submodule update --init themes/introduction

# Build the Hugo site
RUN hugo || (echo "Hugo build failed!" && exit 1)

# Ensure that the public directory exists and move the built site to Nginx HTML folder
RUN if [ -d "public" ]; then mv public/* /usr/share/nginx/html; else echo "public directory not found!"; exit 1; fi

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
