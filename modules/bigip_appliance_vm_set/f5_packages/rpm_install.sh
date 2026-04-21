#!/bin/bash

set -e

CREDS="admin:$1"
AS3_RPM="$2"
DO_RPM="$3"
CURL_FLAGS="--silent --write-out --insecure -u $CREDS"

#Install f5-appsvcs RPM on target
echo "Installing $AS3_RPM"
export AS3_DATA="{\"operation\":\"INSTALL\",\"packageFilePath\":\"/var/config/rest/downloads/$AS3_RPM\"}"
curl $CURL_FLAGS "http://localhost/mgmt/shared/iapp/package-management-tasks" --data $AS3_DATA -H "Origin: http://localhost" -H "Content-Type: application/json;charset=UTF-8"

echo "Waiting for /info endpoint to be available"
until curl ${CURL_FLAGS} -o /dev/null --write-out "" --fail --silent \
    "http://localhost/mgmt/shared/appsvcs/info"; do
    sleep 1
done

echo "Installed $AS3_RPM"

#Install Declarative Onboarding RPM on target
echo "Installing $DO_RPM"
export DO_DATA="{\"operation\":\"INSTALL\",\"packageFilePath\":\"/var/config/rest/downloads/$DO_RPM\"}"
curl $CURL_FLAGS "http://localhost/mgmt/shared/iapp/package-management-tasks" --data $DO_DATA -H "Origin: http://localhost" -H "Content-Type: application/json;charset=UTF-8"

echo "Waiting for /info endpoint to be available"
until curl ${CURL_FLAGS} -o /dev/null --write-out "" --fail --silent \
    "http://localhost/mgmt/shared/declarative-onboarding/info"; do
    sleep 1
done

echo "Installed $DO_RPM"
exit 0