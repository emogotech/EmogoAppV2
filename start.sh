#!/bin/sh
# Start the run once job.
echo "Docker container has been started"

python3.6 manage.py collectstatic --settings=emogo.prod_settings -y

#celery -A sporttechie worker -l info -B > /dev/null 2>&1 &
python3.6 manage.py runserver 0.0.0.0:80 --settings=emogo.prod_settings

exec "$@"
