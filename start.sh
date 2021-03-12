#!/bin/bash

# turn on bash's job control
set -m

# Copy configuration files
cp /recdb-postgresql-dockerized/postgresql.conf /recdb-postgresql-dockerized/PostgreSQL/data/postgresql.conf
cp /recdb-postgresql-dockerized/pg_hba.conf /recdb-postgresql-dockerized/PostgreSQL/data/pg_hba.conf
# Start the primary process and put it in the background
cd /recdb-postgresql-dockerized/PostgreSQL/ || exit
perl scripts/pgbackend.pl &

# Start the helper process
sleep 1
cd /recdb/bin/ && \
./psql -U postgres -d postgres -c "alter user postgres with password 'admin';"
./psql -U postgres -tc "SELECT 1 FROM pg_database WHERE datname = 'recdb'" | grep -q 1 | ./psql -U postgres -c "CREATE DATABASE recdb
  WITH OWNER = postgres
     TEMPLATE = template0
     ENCODING = 'UTF8'
     TABLESPACE = pg_default
     LC_COLLATE = 'C'
     LC_CTYPE = 'C'
     CONNECTION LIMIT = -1;"
./psql -U postgres -d recdb -c "CREATE TABLE IF NOT EXISTS users (
   user_pk serial PRIMARY KEY,
   user_email VARCHAR ( 255 ) NOT NULL
);"
./psql -U postgres -d recdb -c "CREATE TABLE IF NOT EXISTS services (
   service_pk serial PRIMARY KEY,
   service_name VARCHAR ( 255 ) NOT NULL

);"
./psql -U postgres -d recdb -c "CREATE TABLE IF NOT EXISTS view_count (
   user_id INT NOT NULL,
   service_id INT NOT NULL,
   visits REAL NOT NULL,

   PRIMARY KEY (user_id, service_id)
);"

./psql -U postgres -d recdb -c "CREATE RECOMMENDER serviceRec ON view_count USERS FROM user_id ITEMS FROM service_id EVENTS FROM visits USING ItemCosCF ;"

# the my_helper_process might need to know how to wait on the
# primary process to start before it does its work and returns


# now we bring the primary process back into the foreground
# and leave it there
fg %1
