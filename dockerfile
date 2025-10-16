# Use the base image from the requirement
FROM devopsedu/webapp

# Install any necessary PHP dependencies if needed or leave 
#RUN apt-get update && apt-get install -y ...

# The base image likely already has Apache and PHP configured.
# We just need to copy our website code to the appropriate directory.
# Assuming the document root is /var/www/html
# Copy the entire repository content to the web root
COPY website/ /var/www/html/

# Expose port 80
EXPOSE 80

# The base image likely has a CMD already, so we don't need to specify it.
CMD ["apache2ctl","-D","FOREGROUND"]
