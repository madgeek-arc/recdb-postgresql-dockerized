#!/bin/bash
  
# turn on bash's job control
set -m
  
# Start the primary process and put it in the background
cd /recdb-postgresql-dockerized/PostgreSQL/ || exit
perl scripts/pgbackend.pl &
  
# Start the helper process
sleep 1
cd /recdb/bin/ && \
./psql -U postgres -d postgres -c "alter user postgres with password 'admin';"
./psql -U postgres -d postgres -a -f /recdb-postgresql-dockerized/createDB.sql

  
# the my_helper_process might need to know how to wait on the
# primary process to start before it does its work and returns
  
  
# now we bring the primary process back into the foreground
# and leave it there
fg %1
