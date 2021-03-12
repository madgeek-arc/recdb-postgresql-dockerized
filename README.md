# recdb-postgresql-dockerized
A dockerized app for recommendations

# build docker image
In the directory with the Dockerfile run\
`docker build -t recdb .`

# start container
`docker run -d --name recdb -p 5432:5432 --restart=always recdb`