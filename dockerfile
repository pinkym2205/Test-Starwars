# Use Alpine Linux as the base image
FROM alpine:latest

# Install dependencies (curl, jq)
RUN apk --no-cache add curl jq bash

# Set the working directory inside the container
WORKDIR /app

# Copy the script from the local machine to the container
COPY test.sh /app/test.sh

# Make the script executable
RUN chmod +x /app/test.sh

# Set the entrypoint to run the script
ENTRYPOINT ["/bin/bash","./test.sh"]

