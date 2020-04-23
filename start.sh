#!/bin/sh
# Start the run once job.
echo "Docker container has been started"

#python2.7 manage.py collectstatic --yes --settings=emogo.stage_settings
#python2.7 manage.py collectstatic --settings=emogo.stage_settings -y

#celery -A sporttechie worker -l info -B > /dev/null 2>&1 &
python2.7 manage.py runserver 0.0.0.0:80 --settings=emogo.stage_settings

exec "$@"
