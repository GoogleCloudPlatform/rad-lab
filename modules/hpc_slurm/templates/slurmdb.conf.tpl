AuthType=auth/munge
AuthAltTypes=auth/jwt
AuthAltParameters=jwt_key=${STATE_SAVE_LOCATION}/jwt_hs256.key

DbdHost=${CONTROLLER_HOST_NAME}
DebugLevel=debug

LogFile=${LOG_DIRECTORY}/slurmdbd.log
PidFile=/var/run/slurm/slurmdbd.pid

SlurmUser=slurm

StorageLoc=${SLURM_DB_NAME}

StorageType=accounting_storage/mysql
StorageHost=${SLURM_DB_HOST}
StoragePort=${SLURM_DB_PORT}
StorageUser=${SLURM_DB_USER}
StoragePass=${SLURM_DB_PASSWORD}