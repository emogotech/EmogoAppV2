FROM python:3.6

RUN mkdir -p /usr/src/app/

WORKDIR /usr/src/app/


RUN apt-get update

RUN apt-get install -y rabbitmq-server
# INSTALL syslog for debugging my cron jobs
RUN apt-get install -y rsyslog

# Optional: depending on your environment 
RUN apt-get install -y default-jdk

# Install cron
RUN apt-get install cron

COPY requirements.txt /usr/src/app/
RUN pip3 install psycopg2-binary

RUN pip install --no-cache-dir -r requirements.txt

COPY . /usr/src/app/
COPY ./start.sh /usr/src/app/

RUN chmod 777 /usr/src/app
RUN mkdir -p /usr/src/app/logs
RUN touch /usr/src/app/logs/logfile.log
ENTRYPOINT ["/usr/src/app/start.sh"] 
RUN chmod 777 start.sh

EXPOSE 80
CMD ["celery","-A","LetsAllBeHeard","worker","-l","info","-B"]
