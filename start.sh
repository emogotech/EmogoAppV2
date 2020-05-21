#!/bin/sh
# Start the run once job.
echo "Docker container has been started"

#python3.6 manage.py collectstatic --yes --settings=emogo.qa_settings
#python3.6 manage.py collectstatic --settings=emogo.qa_settings -y

#celery -A sporttechie worker -l info -B > /dev/null 2>&1 &

echo "Docker container has been started"

python3.6 manage.py runserver 0.0.0.0:80 --settings=emogo.qa_settings

exec "$@"
