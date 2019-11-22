#/bin/bash
while ! pg_isready -h postgres
do
  echo "$(date) - waiting for database to start"
  sleep 1
done
