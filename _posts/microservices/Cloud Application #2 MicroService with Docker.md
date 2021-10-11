---
title: "Create a custom *.onion URL with Shallot"
categories:
  - Post Formats
tags:
  - chat
  - Post Formats
---
## Prerequisites  

- A working MicroService (Tutorial: [Java MicroService]([https://whit-e.com/articles/building-java-rest-api](https://whit-e.com/articles/building-java-rest-api)) or [Node.JS MicroService]([https://whit-e.com/articles/building-nodejs-rest-api](https://whit-e.com/articles/building-nodejs-rest-api)))
- Docker installed on your server (example on Ubuntu: following Steps 1 and 2 of [How To Install and Use Docker on Ubuntu 18.04](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-18-04))
- *Optional: a Docker Hub account
## About the Dockerfile
### What is the Dockerfile?
A Dockerfile is a simple text file that describes the structure of our Docker image.
It contains multiple different commands, which make sure that the base image is pulled, our microservice gets into the image, ports are monitored and e.g. the application is started.
All important commands for this tutorial are described here:
### Commands:
#### FROM
The most important command in the docker file is FROM. This must be at the top and simply describes which image to use as the basis for our newly created image. This can be basic images like ubuntu or ubuntu:trusty but also images created by users (or ourselves).
#### RUN
One of the most important commands is certainly the ``RUN`` command. This command simply executes the parameter as a shell command, giving us the flexibility to do virtually anything in our virtual machine. The ``RUN sudo apt-get install -y npm`` is translated internally to ``/bin/sh -c sudo apt-get install -y npm``

A second way to execute the RUN command is with the so-called exec syntax. ``RUN ["executable", "param1", "param2"]``

In many cases our Dockerfiles will be a sequence of many RUN commands. 
Info: *Each RUN command creates a new layer in the image - consumes memory. That means we should keep the number as low as possible and do several things within one command.*

#### WORKDIR
Each RUN, CMD, ADD and COPY command starts from the root directory. If we want to change this, the ``WORKDIR`` command works quite simply. It sets the new reference directory for all following commands (or until the next call of WORKDIR).
``WORKDIR /opt/app``

#### COPY
COPY is a command that takes a file or directory from the host system and inserts it into the file system of the image. The syntax is very simple:
``COPY app /opt``
First comes the directory or file to be copied and second the destination. 

#### EXPOSE
An important point at Docker is communication inside and outside the containers. To do this, ports must be opened and the ``EXPOSE`` command takes care of that. For example, if we want to run our node service inside a container, we can do this with
``EXPOSE 3000``
This will ensure that port 3000 is monitored.

#### CMD
``CMD`` provides a container created from our image with a standard command that is executed. This command can of course be overwritten by the container. There can **only** be **one** CMD command per Dockerimage, if several are defined only the last one is valid. From the syntax CMD works exactly like RUN.
``CMD echo "visit whit-e.com for more!"``

## The Dockerfile (Node.js)
Our new created, empty ``Dockerfile`` is always located in the root directory of the project.
For our Node.js application it looks like this:
```dockerfile
FROM node:10-alpine

# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
# where available (npm@5+)
COPY package*.json ./
RUN npm install

# If you are building your code for production
# RUN npm ci --only=production
# Bundle app source
COPY . .

# Watches for Port 8080
EXPOSE 8080

# Run the start command, which is defined at our package.json
CMD [ "npm", "start" ]
```

Info: *If this tutorial is not enough for you and you want a more detailed one for the dockerizing of your Node.js app then you can find one at node too: https://nodejs.org/en/docs/guides/nodejs-docker-webapp/*

## The Dockerfile (Java / Gradle)
Our new created, empty ``Dockerfile`` is always located in the root directory of the project.
For our Java application it looks like this:
```dockerfile
FROM gradle:jdk8 as builder
  
# Create a new Directory called application
RUN mkdir application

# Add our gradle files there
ADD build.gradle application
ADD settings.gradle application
# And add our src directory there
ADD src application/src

# Set the workdir to `application`
WORKDIR application

# Run gradle for creating a clean jar
RUN gradle clean build --stacktrace --info


# Now we use a clean jre8-slim img only for our application
FROM frolvlad/alpine-oraclejre8:slim
# Copy the jar there
COPY --from=builder /home/gradle/application/build/libs/Blueprint-latest.jar /app/
# Set the workdir to /app
WORKDIR /app
# Set the entrypoint
ENTRYPOINT ["java", "-jar", "Blueprint-latest.jar"]
```
Info: *If you have another process how to create a jar then you can save yourself the upper process with gradle of course.  Alternatively you can copy your java class files and run the application directly.*
*In a other tutorial - which will be about CI/CD - we will outsource the building of the jars from the dockerfile to a job in the ci-pipeline.*

## Building your image

Go to the directory/project that has your  `Dockerfile`  and run the following command to build the Docker image. The  `-t`  flag lets you tag your image so it's easier to find later using the  `docker images`  command:

```bash
docker build -t <your username>/node-api .
# or for the java file
docker build -t <your username>/java-api .
```

Your image will now be listed by Docker:

```bash
$ docker images

# Example
REPOSITORY                   TAG                 IMAGE ID            CREATED             SIZE
<your username>/java-api     latest              f1696fc64aa8        3 minutes ago       136MB
<your username>/node-api     latest              7e5548e3f5de        33 minutes ago      88.9MB
gradle                       jdk8                951aca94658f        36 hours ago        553MB
node                         10-alpine           b95baba1cfdb        2 months ago        76.4MB
frolvlad/alpine-oraclejre8   slim                732243639a95        9 months ago        123MB
```
## Run your Image

Running your image with  `-d`  runs the container in detached mode, leaving the container running in the background. The  `-p`  flag redirects a public port to a private port inside the container. So if our application normally runs on port 3000 or 3001, we can redirects them to 8080.  Inside the container the application will run on the defined app port (e.g. 3000) but outside the container we can access port 8080 via the host. Docker handles the port mapping for us hereRun the image you previously built:

```bash

#docker run -p publicPort:innerPortOfApplication -d <your username>/node-api
docker run -p 8080:3000 -d <your username>/node-api
docker run -p 8081:3001 -d <your username>/java-api
```

Print the output of your app:

```bash
# Get container ID
$ docker ps

# Print app output
$ docker logs <container id>

# Example
Running on http://localhost:8080 # -> our nodejs api
Running on http://localhost:8081 # -> our java api
```

If you need to go inside the container you can use the  `exec`  command:
```bash
# Enter the container
$ docker exec -it <container id> /bin/bash
```

## Access to our local MySQL
Our docker containers are now running smoothly and we can also call our services under the appropriate paths.
However, we use a local MySQL in which the corresponding data is stored. To access this data we have to change the host of the database from: ``localhost`` to ``host.docker.internal``
Info: *If this doesn't work for you, you have to find out the local ip of your host with ``ifconfig`` and use it accordingly (which would also be my recommendation, because then your service will continue to run locally without any different settings)*
