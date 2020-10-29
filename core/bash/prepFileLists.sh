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

########################################
# Data Accelerator for AI and Analytics
# Sample AFM Prefetch / Evict Filelist Generation
# simple example for single NFS, OBJ, Scale AFM relationships

SCRIPT_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# input params
while [ "$1" != "" ]
do
   case "$1" in
   '-id')
      UNIQUE=$2
      shift
      ;;
   '-files')
      FILES=$2
      shift 
      ;;
   '-type')
      TYPE=$2
      shift
      ;;
   '-arconly')
      ARCONLY=$2
      shift
      ;;
   esac
   shift
done

if [ -z "$TYPE" ] || [ -z "$FILES" ] || [ -z "$TYPE" ]
then
      echo "id, files and type are needed"
	  exit 1
fi


# source the defaults
source ${SCRIPT_PATH}/daaa_config ${UNIQUE}

if [[ -z "$ARCONLY" ]]; then
    rm -rf ${BASE_TMP}${UNIQUE}_${TYPE}list_*.txt
else
    rm -rf ${BASE_TMP}${UNIQUE}_${TYPE}list_*archive.txt
fi

while IFS=',' read path filename datasource platform state; do
    platform=$(echo ${platform// /_})
    if [[ -z "$ARCONLY" ]] && [[ "${platform}${datasource}" == "${DISCOVER_CONNECTION_PLATFORM_NFS// /_}${DISCOVER_CONNECTION_DATASOURCE_NFS}" ]]; then
        path=$(echo ${path//"${NFS_SERVER_BASE_PATH}"})
        echo ${GPFS_FS_PATH}${NFS_FSET}/${path}${filename} >> ${BASE_TMP}${UNIQUE}_${TYPE}list_${platform}.txt
    elif [[ -z "$ARCONLY" ]] && [[ "${platform}${datasource}" == "${DISCOVER_CONNECTION_PLATFORM_OBJ// /_}${DISCOVER_CONNECTION_DATASOURCE_OBJ}" ]]; then
        echo ${GPFS_FS_PATH}${COS_FSET}/${filename} >> ${BASE_TMP}${UNIQUE}_${TYPE}list_${platform}.txt
    elif [[ "${platform}${datasource}" == "${DISCOVER_CONNECTION_PLATFORM_ARC// /_}${DISCOVER_CONNECTION_DATASOURCE_ARC}" ]]; then
        if [[ "$TYPE" == "prefetch" ]]; then
	     if [[ "$state" != "resdnt" ]] && [[ "$state" != "premig" ]]; then
                  echo ${path}${filename} >> ${BASE_TMP}${UNIQUE}_${TYPE}list_${platform}_archive.txt
             fi
        else
             if [[ "$state" != "migrtd" ]]; then
                  echo ${path}${filename} >> ${BASE_TMP}${UNIQUE}_${TYPE}list_${platform}_archive.txt
             fi
        fi
        if [[ -z "$ARCONLY" ]]; then
             path=$(echo ${path//"${ARCHIVE_BASE_PATH}"})
             echo ${GPFS_FS_PATH}${ARC_FSET}/${path}${filename} >> ${BASE_TMP}${UNIQUE}_${TYPE}list_${platform}.txt
        fi
    fi
done < $FILES

if [[ "$TYPE" == "prefetch" ]]; then
    cp ${BASE_TMP}${UNIQUE}_prefetchlist_${DISCOVER_CONNECTION_PLATFORM_NFS// /_}.txt ${BASE_TMP}${UNIQUE}_evictlist_${DISCOVER_CONNECTION_PLATFORM_NFS// /_}.txt 2>/dev/null || :
    cp ${BASE_TMP}${UNIQUE}_prefetchlist_${DISCOVER_CONNECTION_PLATFORM_OBJ// /_}.txt ${BASE_TMP}${UNIQUE}_evictlist_${DISCOVER_CONNECTION_PLATFORM_OBJ// /_}.txt 2>/dev/null || :
    cp ${BASE_TMP}${UNIQUE}_prefetchlist_${DISCOVER_CONNECTION_PLATFORM_ARC// /_}.txt ${BASE_TMP}${UNIQUE}_evictlist_${DISCOVER_CONNECTION_PLATFORM_ARC// /_}.txt 2>/dev/null || :
fi


exit 0
