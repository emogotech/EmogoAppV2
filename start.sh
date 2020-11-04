#!/bin/sh
# Start the run once job.
echo "Docker container has been started"
service redis-server start 


#python3.6 manage.py collectstatic --yes --settings=emogo.settings
#python3.6 manage.py collectstatic --settings=emogo.settings -y

#celery -A sporttechie worker -l info -B > /dev/null 2>&1 &

echo "Docker container has been started"
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-3.3.0.1492-linux.zip
unzip sonar-scanner-cli-3.3.0.1492-linux.zip
export PATH=$PATH:./sonar-scanner-3.3.0.1492-linux/bin/
export SONAR_SCANNER_OPTS="-Xmx512m"
mkdir -p /codebuild/output/src857048737/src/sonar-scanner-3.3.0.1492-linux/conf/
cp sonar-scanner.properties /codebuild/output/src857048737/src/sonar-scanner-3.3.0.1492-linux/conf/sonar-scanner.properties
cat /codebuild/output/src857048737/src/sonar-scanner-3.3.0.1492-linux/conf/sonar-scanner.properties
cp sonar-scanner.properties sonar-scanner-3.3.0.1492-linux/conf/sonar-scanner.properties

# python3.6 manage.py test -k

#echo $?

# if [ $? -eq 0 ]
# then
#   echo "posting data to sonarqube after maven build"
sonar-scanner -Dsonar.projectKey=$KEY -Dsonar.sources=. -Dsonar.host.url=$URL -Dsonar.login=$TOKEN
# else
#   echo "Build failed"
# fi
python3.6 manage.py runserver 0.0.0.0:80 --settings=emogo.settings
uwsgi --http :80 --module emogo.wsgi --process 4


exec "$@"
