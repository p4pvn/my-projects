#!/bin/bash

export PATH=/bin:/usr/bin:/usr/local/bin
TODAY=$(date +"%d-%m-%Y-%H-%M")
TIME=$(date +"%d-%m-%Y-%H-%M")

LOGDIR="/apps/mfgpro/build/logs"
EMAILLIST="pradeepsinh@alitersolutions.com pawan@alitersolutions.com"
DB_BACKUP_PATH="/backup/MongoDBbackup"
DB_BACKUP_ARCHIVE_PATH="/backup/MongoDBbackup_TarFiles"
MONGO_HOST="10.9.0.5"
MONGO_PORT="27017"
LOGFLNM1="$LOGDIR/azdbbackupcurl.log"

# Authentication
AUTH_ENABLED=1

client="dinshaw"
MONGO_USER="MongoAdmin"

# fetch secret, decode, and fail if anything goes wrong

MONGO_PASSWD=$(curl -fsSL "https://secrets.alitersolutions.com/mongo/${client}/password" | base64 --decode) || {
  echo "ERROR: failed to fetch/decode secret" >&2
  exit 1
}

# sanity check
if [ -z "$MONGO_PASSWD" ]; then
  echo "ERROR: secret is empty" >&2
  exit 1
fi

# Database names ("ALL" or space-separated names)
DATABASE_NAMES="ALL"


main_function() {

    echo "#####################################################################"
    echo "################  MongoDB Backup Script is Started  #################"
    echo "#####################################################################"

    echo "#####################################################################"
    echo "############# Removing Older DB Backup files from System ############"
    echo "#####################################################################"

    rm -rf "$DB_BACKUP_PATH"/*
    echo "### Removed old backups from: $DB_BACKUP_PATH"
    echo

    echo "######################################################################"
    echo "############# Start Taking Backup of Mongo Databases #################"
    echo "######################################################################"
    echo

    mkdir -p "${DB_BACKUP_PATH}/${TODAY}"

    AUTH_PARAM=""
    if [ "$AUTH_ENABLED" -eq 1 ]; then
        AUTH_PARAM="--username ${MONGO_USER} --password ${MONGO_PASSWD}"
    fi

    if [ "$DATABASE_NAMES" = "ALL" ]; then
        echo "Backing up ALL databases..."
        nice -n 19 ionice -c2 -n7 cpulimit -l 40 -- \
            mongodump --host "$MONGO_HOST" --port "$MONGO_PORT" \
            $AUTH_PARAM --out "${DB_BACKUP_PATH}/${TODAY}/"
    else
        echo "Running backup for selected databases..."
        for DB_NAME in $DATABASE_NAMES; do
            nice -n 19 ionice -c2 -n7 cpulimit -l 40 -- \
                mongodump --host "$MONGO_HOST" --port "$MONGO_PORT" \
                --db "$DB_NAME" $AUTH_PARAM --out "${DB_BACKUP_PATH}/${TODAY}/"
        done
    fi

    echo
    echo "######## Converting DB folder to Tar File before Blob Sync #########"
    echo

    rm -rf "${DB_BACKUP_ARCHIVE_PATH}"/*
    tar -cPvf "${DB_BACKUP_ARCHIVE_PATH}/MongoBackup_${TODAY}.tar.gz" /backup/MongoDBbackup
    echo "Tar file created at: ${DB_BACKUP_ARCHIVE_PATH}"
    echo

    echo "####### Starting Sync to Azure Blob Container [db-backup-evolve] #######"
    echo

    nice -n 19 ionice -c2 -n7 cpulimit -l 50 -- \
        azcopy sync "${DB_BACKUP_ARCHIVE_PATH}/" \
        "https://dinshawicecreams.blob.core.windows.net/db-backup-evolve?sp=racwl&st=2023-04-04T07:37:58Z&se=2030-03-31T15:37:58Z&spr=https&sv=2021-12-02&sr=c&sig=${sqs-token}" \
        --cap-mbps 90

    echo "###### Successfully Synced with Blob Container ######"
    echo
    echo "######################### End of Script ##############################"
    echo
}

main_function 2>&1 >> "$LOGDIR/mongodbbackuptoblob_${TIME}.log"

cd "$LOGDIR"

echo "MongoDB synced successfully to Azure Blob. Please check the attached log." |
mailx -s "DINSHAW PROD SERVER - MongoDB Backup - $TODAY" \
      -a "$LOGDIR/mongodbbackuptoblob_${TIME}.log" $EMAILLIST > /dev/null 2>&1

curl --location \
  'https://crm.alitersolutions.com/Monitoring/CroneJob/AddQadCroneJobDetails' \
  --form "blob=@${LOGDIR}/mongodbbackuptoblob_${TIME}.log" \
  --form "metadata={\"EvolveCustomer_Code\":\"DINSHAW\",\"EvolveCustomerTenant_Code\":\"MT-PRODUCTION\",\"EvolveCroneJob_Code\":\"MONGO30BKUP\",\"EvolveCroneJob_RunTime\":\"$(date +%Y-%m-%dT%H:%M:%S)\"};type=application/json" \
  >> "$LOGFLNM1"
