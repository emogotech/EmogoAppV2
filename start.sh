#!/bin/sh
# Start the run once job.
echo "Docker container has been started"

#python3.6 manage.py collectstatic --yes --settings=emogo.qa_settings
#python3.6 manage.py collectstatic --settings=emogo.qa_settings -y

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
sonar-scanner -Dsonar.projectKey=emogo -Dsonar.sources=. -Dsonar.host.url=http://111.118.247.26:8090 -Dsonar.login=47ef3196843afe07e7f1de330550fcc42aca848e
# else
#   echo "Build failed"
# fi
python3.6 manage.py runserver 0.0.0.0:80 --settings=emogo.qa_settings

exec "$@"
