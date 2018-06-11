# Dockerized Spring boot 2 application

![Docker plus Spring Boot plus Codefresh](docker-spring-boot-codefresh.jpg)

This is an example Java application that uses Spring Boot 2 and Docker.
It is compiled using Codefresh

## Instructions

To compile (also runs unit tests)

```
mvn package
```

## To run integration tests

```
mvn verify
```

## To run the webapp manually

```
mvn spring-boot:run
```

....and navigate your browser to  http://localhost:8080/

## To create a docker image

```
mvn package
docker build -t my-spring-boot-sample .
```


## To run the docker image

```
docker run -p 8080:8080 my-spring-boot-sample
```

The Dockerfile also has a healthcheck

## To use this project in Codefresh 

There is also a [codefresh.yml](codefresh.yml) for easy usage with the [Codefresh](codefresh.io) CI/CD platform.



See the [multi-stage-docker branch](https://github.com/codefresh-contrib/spring-boot-2-sample-app/tree/multi-stage-docker) of this repo for a [Dockerfile](https://github.com/codefresh-contrib/spring-boot-2-sample-app/blob/multi-stage-docker/Dockerfile) that uses multi-stage builds and the respective [codefresh.yml](https://github.com/codefresh-contrib/spring-boot-2-sample-app/blob/multi-stage-docker/codefresh.yml)


Enjoy!

