FROM python:3.6
RUN mkdir -p /usr/src/app/

WORKDIR /usr/src/app/

RUN apt-get update

RUN apt-get install -y rabbitmq-server

COPY requirements.txt /usr/src/app/


RUN pip install --no-cache-dir -r requirements.txt

COPY . /usr/src/app/
COPY ./start.sh /usr/src/app/

ENTRYPOINT ["/usr/src/app/start.sh"]
RUN chmod 777 start.sh
# RUN python3.6 manage.py makemigrations

# # RUN python3.6 manage.py migrate --settings=emogo.stage_settings

# RUN python3.6 manage.py common_script --settings=emogo.stage_settings
# RUN python3.6 manage.py loaddata questions question_type age location payout_structure --settings=emogo.stage_settings

EXPOSE 80

# CMD celery -A clout worker -l info -B> /dev/null 2>&1 & python3.6 manage.py runserver 0.0.0.0:8000 --settings=emogo.stage_settings
# # python3.6 manage.py runserver 0.0.0.0:8000 &&

CMD ["celery","-A","emogo","worker","-l","info","-B"]