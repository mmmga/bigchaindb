#!/bin/bash

set -euo pipefail

MONGODB_BACKUP_CONF_FILE=/etc/mongodb-mms/backup-agent.config

mms_api_key=`printenv MMS_API_KEY`
ca_crt_path=`printenv CA_CRT_PATH`
backup_crt_path=`printenv BACKUP_PEM_PATH`

if [[ -z "${mms_api_key}" || \
    -z "${ca_crt_path}" || \
    -z "${backup_crt_path}" ]]; then
  echo "Invalid environment settings detected. Exiting!"
  exit 1
fi

sed -i '/mmsApiKey/d'  ${MONGODB_BACKUP_CONF_FILE}
sed -i '/mothership/d'  ${MONGODB_BACKUP_CONF_FILE}

echo "mmsApiKey="${mms_api_key} >> ${MONGODB_BACKUP_CONF_FILE}
echo "mothership=api-backup.eu-west-1.mongodb.com" >> ${MONGODB_BACKUP_CONF_FILE}

# Append SSL settings to the config file
echo "useSslForAllConnections=true" >> ${MONGODB_BACKUP_CONF_FILE}
echo "sslRequireValidServerCertificates=true" >> ${MONGODB_BACKUP_CONF_FILE}
echo "sslTrustedServerCertificates="${ca_crt_path} >> ${MONGODB_BACKUP_CONF_FILE}
echo "sslClientCertificate="${backup_crt_path} >> ${MONGODB_BACKUP_CONF_FILE}
echo "#sslClientCertificatePassword=<password>" >> ${MONGODB_BACKUP_CONF_FILE}

echo "INFO: starting mdb backup..."
exec mongodb-mms-backup-agent -c $MONGODB_BACKUP_CONF_FILE
