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
# Sample Main Job Control, Starting Sub Jobs

cd

########################################
# Cleanup any LSF environment variables
for VAR in `env | egrep '(LS|BSUB|JOB_)' | awk 'BEGIN{FS="="}{print $1}'`
do
   unset $VAR
done
LSF_ENVDIR=/shared/lsf/conf
# Source the LSF environment fresh
. ${LSF_ENVDIR}/profile.lsf
########################################

SCRIPT_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# generate unique if for the whole job
UNIQUE=`date +%Y%m%d-%Hh%Mm%S`

# source the defaults
source ${SCRIPT_PATH}/daaa_config ${UNIQUE}

# store arguments in a special array 
args=("$@") 
# get number of elements 
ELEMENTS=${#args[@]} 
 
# echo each element in array  
# for loop 
for (( i=0;i<$ELEMENTS;i++)); do 
    echo ${args[${i}]} >> ${LSF_ARGS}
done

# check with discover
bsub -J "searchDiscover_${UNIQUE}" ${SCRIPT_PATH}/searchDiscover.sh ${UNIQUE}

# check if data needs to be recalled from tape
bsub -J "recallDataIn_${UNIQUE}" -w "searchDiscover_${UNIQUE}" ${SCRIPT_PATH}/recallArchive.sh ${UNIQUE}

# cache data in
bsub -J "cacheDataIn_${UNIQUE}" -w "recallDataIn_${UNIQUE}" ${SCRIPT_PATH}/cacheDataIn.sh ${UNIQUE}

# run the magic on the cached data
#bsub -J "runAnalytics_${UNIQUE}" -w "cacheDataIn_${UNIQUE}" ${SCRIPT_PATH}/runAnalyticsDummy.sh ${UNIQUE}
bsub -J "runAnalytics_${UNIQUE}" -w "cacheDataIn_${UNIQUE}" ${SCRIPT_PATH}/runAnalytics.sh ${UNIQUE}
#bsub -J "runAnalytics_${UNIQUE}" -w "cacheDataIn_${UNIQUE}" /home/dean/daaa/yaml/runAnalyticsWr.sh ${UNIQUE}

# check again with discover (state might have changed)
bsub -J "searchDiscoverC_${UNIQUE}" -w "runAnalytics_${UNIQUE}" ${SCRIPT_PATH}/searchDiscover.sh ${UNIQUE}

# free up cache space
bsub -J "evictDataOut_${UNIQUE}" -w "searchDiscoverC_${UNIQUE}" ${SCRIPT_PATH}/evictDataOut.sh ${UNIQUE}

# check if data can be migrated back to tape
bsub -J "migrateDataOut_${UNIQUE}" -w "evictDataOut_${UNIQUE}" ${SCRIPT_PATH}/migrateArchive.sh ${UNIQUE}

# cleanup tmp files
#bsub -J "cleanup_${UNIQUE}" -w "migrateDataOut_${UNIQUE}" ${SCRIPT_PATH}/cleanup.sh ${UNIQUE}

sleep 20

