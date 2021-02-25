FROM ubuntu:18.04

RUN apt-get -y update && \
    apt-get -y install gcc && \
    apt-get -y install make && \
    apt-get -y install libreadline-dev && \
    apt-get -y install bison && \
    apt-get -y install zlib1g-dev && \
    apt-get -y install git && \
    apt-get -y install nano && \
    apt-get -y install wget

#Downloading a specific version of flex
RUN wget https://launchpad.net/ubuntu/+source/flex/2.5.31-31/+build/88281/+files/flex_2.5.31-31_amd64.deb

#Flex would put a warning/error message that would interrupt the build, added forcefully 0 exit code.
RUN dpkg -i flex_2.5.31-31_amd64.deb ; exit 0

# Postgres group, user and stuff
RUN set -eux; \
	groupadd -r postgres --gid=999; \
# https://salsa.debian.org/postgresql/postgresql-common/blob/997d842ee744687d99a2b2d95c1083a2615c79e8/debian/postgresql-common.postinst#L32-35
	useradd -r -g postgres --uid=999 --home-dir=/var/lib/postgresql --shell=/bin/bash postgres; \
# also create the postgres user's home directory with appropriate permissions
# see https://github.com/docker-library/postgres/issues/274
	mkdir -p /var/lib/postgresql; \
	chown -R postgres:postgres /var/lib/postgresql

RUN mkdir /recdb && \
	mkdir /recdb-postgresql && \
	git clone https://github.com/DataSystemsLab/recdb-postgresql.git && \
	chown -R postgres:postgres /recdb /recdb-postgresql

USER postgres

RUN	cd recdb-postgresql/PostgreSQL/ && \
	perl ./scripts/install.pl /recdb 

# USER root

# RUN	ln -s recdb/bin/psql /usr/bin/psql && \
#	perl -i -pe 's/#listen_addresses = 'localhost'/listen_addresses = '*'/g' /recdb-postgresql/PostgreSQL/data/postgresql.conf

# USER postgres

EXPOSE 5432

CMD cd /recdb-postgresql/PostgreSQL/ && \
	perl scripts/pgbackend.pl
