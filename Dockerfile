FROM python:3.6
RUN mkdir -p /usr/src/app/

WORKDIR /usr/src/app/

COPY requirements.txt /usr/src/app/

RUN pip install --no-cache-dir -r requirements.txt

COPY . /usr/src/app/

COPY ./start.sh /usr/src/app/

ENTRYPOINT ["/usr/src/app/start.sh"]

RUN chmod 777 start.sh

EXPOSE 80
