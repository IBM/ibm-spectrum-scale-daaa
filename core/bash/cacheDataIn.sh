#!/bin/sh

#
# Copyright 2020 IBM Corporation
# and other contributors as indicated by the @author tags.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

########################################
# Data Accelerator for AI and Analytics
# Sample AFM Prefetch Execution

# unique id for the job
UNIQUE=$1

SCRIPT_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# source the defaults
source ${SCRIPT_PATH}/daaa_config ${UNIQUE}


for file in ${BASE_TMP}${UNIQUE}_prefetchlist_*
do
    if [[ -f $file ]] && [[ $file != *"archive"* ]]; then
        scp $file ${ESS3K_MGMT_USER}@${ESS3K_MGMT_SERVER}:${ESS3K_MGMT_HOME_PATH}DAAA/
        file=${file//$BASE_TMP/}
        if [[ "$file" == *${DISCOVER_CONNECTION_PLATFORM_NFS// /_}.txt ]]; then
            ssh ${ESS3K_MGMT_USER}@${ESS3K_MGMT_SERVER} ${ESS3K_MGMT_HOME_PATH}DAAA/afmExec.sh "prefetch" ${GPFS_FS} ${NFS_FSET} ${ESS3K_MGMT_HOME_PATH}DAAA/${file} ${CONTENT_FILE} ${GPFS_FS_PATH} &
            pids[${i}]=$!
        elif [[ "$file" == *${DISCOVER_CONNECTION_PLATFORM_OBJ// /_}.txt ]]; then
            ssh ${ESS3K_MGMT_USER}@${ESS3K_MGMT_SERVER} ${ESS3K_MGMT_HOME_PATH}DAAA/afmExec.sh "prefetch" ${GPFS_FS} ${COS_FSET} ${ESS3K_MGMT_HOME_PATH}DAAA/${file} ${CONTENT_FILE} ${GPFS_FS_PATH} &
            pids[${i}]=$!
        elif [[ "$file" == *${DISCOVER_CONNECTION_PLATFORM_ARC// /_}.txt ]]; then
            ssh ${ESS3K_MGMT_USER}@${ESS3K_MGMT_SERVER} ${ESS3K_MGMT_HOME_PATH}DAAA/afmExec.sh "prefetch" ${GPFS_FS} ${ARC_FSET} ${ESS3K_MGMT_HOME_PATH}DAAA/${file} ${CONTENT_FILE} ${GPFS_FS_PATH} &
            pids[${i}]=$!
        fi
    fi
done

# wait for all to finish and then return to signal LSF we are done with the job
for pid in ${pids[*]}; do
    wait $pid
done

exit 0
