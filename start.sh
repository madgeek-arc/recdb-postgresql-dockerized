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
./psql -U postgres -d recdb -c "CREATE TABLE IF NOT EXISTS recommendationTable (
   user_email VARCHAR ( 255 ) NOT NULL,
   service_id VARCHAR ( 255 ) NOT NULL,
   visits INT NOT NULL,

   PRIMARY KEY (user_email, service_id)
);"

# the my_helper_process might need to know how to wait on the
# primary process to start before it does its work and returns
  
  
# now we bring the primary process back into the foreground
# and leave it there
fg %1
