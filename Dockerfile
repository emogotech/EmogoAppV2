FROM python:3.6

RUN mkdir -p /usr/src/app/

WORKDIR /usr/src/app/

RUN apt-get update

RUN apt-get install -y redis-server

COPY requirements.txt /usr/src/app/
RUN pip3 install psycopg2-binary


RUN pip3 install --no-cache-dir -r requirements.txt

COPY . /usr/src/app/
COPY ./start.sh /usr/src/app/
RUN 2to3 -w /usr/local/lib/python3.6/site-packages/apns.py
RUN chmod 777 /usr/src/app
RUN mkdir -p /usr/src/app/logs
RUN touch /usr/src/app/logs/logfile.log
ENTRYPOINT ["/usr/src/app/start.sh"]
RUN chmod 777 start.sh

EXPOSE 80
#CMD ["celery","-A","emogo","worker","-l","info","-B"]
#CMD ["daphne", "-b", "0.0.0.0", "-p", "80", "emogo.asgi:application"]

