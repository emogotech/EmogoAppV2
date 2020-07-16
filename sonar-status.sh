#!/bin/sh
PROJECTKEY="emogo-v2"
QGSTATUS=`curl -s -u 76c331471abbd6a9a56d566ca7f13a42f9aef107: http://sonar.northout.net/api/qualitygates/project_status?projectKey=emogo-v2 | jq '.projectStatus.status' | tr -d '"'`
if [ "$QGSTATUS" = "OK" ]
then
exit 0
elif [ "$QGSTATUS" = "ERROR" ]
then
exit 1
fi 
