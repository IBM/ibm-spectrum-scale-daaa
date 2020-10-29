#!/bin/bash
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

# i.e.: ./newDataListener.sh 1 /home/moadmin/kafkaevents
# This sample code works for watching a single bucket
# Enhance the kafka queue watch by storing and validating mutliple bucket names
timeoutMin=$1
logFile=$2

EXEC_SERVER="dean@192.168.1.200"
WATCH_ACTIVE=false

echo "Watching ${logFile} for new file ingestion"
while true
do
    tmp=$(find ${logFile} -maxdepth 0 -mmin -${timeoutMin})
    if [[ -z "$tmp" ]] ; then
        if [[ "$WATCH_ACTIVE" = true ]] ; then
            echo "No new data after ${timeoutMin} minute(s), trigger workload..."
            bucket_name=$( awk -F, '{print $4}' <<< $(tail -1 ${logFile}) )
            bucket_name=$(echo "$bucket_name" | tr -d '\"')     # remove quotes
            bucket_name=$(echo ${bucket_name//"bucket_name:"})  # remove text
            ssh ${EXEC_SERVER} "/usr/local/bin/DAAA/autoJobExecAfterIngest.sh IBM_COS "${bucket_name}
            WATCH_ACTIVE=false
        fi
    else
        if [[ "$WATCH_ACTIVE" = false ]] ; then
            type_event=$( awk -F, '{print $3}' <<< $(tail -1 ${logFile}) )
            # only activate watch if the event is an object write event
            if [[ "$type_event" == *"Object:Write"* ]] ; then
                WATCH_ACTIVE=true
                echo "New data detected, waiting for data ingest to finish..."
            fi
        fi
    fi
    #echo $WATCH_ACTIVE
    sleep 30
done

