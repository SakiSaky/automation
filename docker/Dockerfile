# Use the Ubuntu 18.04 base image
FROM ubuntu:18.04

# Synchronize container localtime with the host
RUN ln -fs /etc/localtime /etc/localtime

# Run the date command 
CMD ["sh", "-c", "date +%s"]
