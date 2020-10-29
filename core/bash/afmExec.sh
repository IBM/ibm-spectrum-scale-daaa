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

#<licence & copyright needed>
########################################
# Data Accelerator for AI and Analytics
# Sample AFM Prefetch / Evict Control

ACTION=$1
GPFS_FS=$2
GPFS_FSET=$3
FILE_LIST=$4
CONTENT_FILE=$5
GPFS_FS_PATH=$6


function download_time_mmpmon() {
  local fs=${1}
  local fset=${2}
  local period=2

  local retry=2
  local retry_notready=2

  local queued=
  local inflight=
  local completed=
  local mmpmon_file=/tmp/mmpmon
  local start=$(date +%s)
  for (( ; ; )); do
    # read inflight is 3rd param
    echo afm_s | /usr/lpp/mmfs/bin/mmpmon &>${mmpmon_file}
    queued=$(cat ${mmpmon_file} | grep read | awk '{print $2}')
    inflight=$(cat ${mmpmon_file} | grep read | awk '{print $3}')
    completed=$(cat ${mmpmon_file} | grep read | awk '{print $4}')
    if [ -n "${queued}" ] && [ -n "${inflight}" ] && [ -n "${completed}" ]; then
      if ! [[ ${inflight} =~ ^[0-9]+$ ]]; then
        retry=$((${retry} - 1))
        if [ ${retry} -eq 0 ]; then
          cat ${mmpmon_file}
          return 1
        fi
      elif [ ${queued} -eq 0 ] && [ ${inflight} -eq 0 ] && [ ${completed} -gt 0 ]; then
        stop=$(date +%s)
        diff=$((${stop} - ${start}))
        break
      fi
    else
      retry_notready=$((${retry_notready} - 1))
      if [ ${retry_notready} -eq 0 ]; then
        cat ${mmpmon_file}
        return 1
      fi
    fi
    sleep ${period}
  done
  return 0
}

# execute afm prefetch / evict
if [[ ${ACTION} == "prefetch" ]]; then
    /usr/lpp/mmfs/bin/mmafmctl ${GPFS_FS} prefetch -j ${GPFS_FSET} --list-file ${FILE_LIST} --force --prefetch-threads 16 --gateway local
else
    /usr/lpp/mmfs/bin/mmafmctl ${GPFS_FS} evict -j ${GPFS_FSET} --list-file ${FILE_LIST}
fi


# monitor afm action till done
download_time_mmpmon ${GPFS_FS} ${GPFS_FSET}


# provide list of content cached
if [[ ${CONTENT_FILE} == "yes" ]]; then
    if [[ ${ACTION} == "prefetch" ]]; then
        cp ${FILE_LIST} /tmp/content.txt
        sed -i -e 's:'${GPFS_FS_PATH}${GPFS_FSET}'/::g' /tmp/content.txt
        cp /tmp/content.txt ${GPFS_FS_PATH}${GPFS_FSET}/content.txt
    else
        echo "" > /tmp/content.txt
        cp /tmp/content.txt ${GPFS_FS_PATH}${GPFS_FSET}/content.txt
    fi
fi


exit 0
