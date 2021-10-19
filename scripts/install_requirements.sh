#!/bin/bash
service rabbitmq-server start
export C_FORCE_ROOT='true'



source /home/ubuntu/EmogoAppV2/venv/bin/activate
mkdir /home/ubuntu/EmogoAppV2/logs && chmod 777 /home/ubuntu/EmogoAppV2/logs
touch /home/ubuntu/EmogoAppV2/logs/debug.log
cd /home/ubuntu/EmogoAppV2



/home/ubuntu/EmogoAppV2/venv/bin/pip install --no-cache-dir -r requirements.txt



#/home/ubuntu/EmogoAppV2/venv/bin/python manage.py makemigrations --merge
/home/ubuntu/EmogoAppV2/venv/bin/python manage.py migrate
