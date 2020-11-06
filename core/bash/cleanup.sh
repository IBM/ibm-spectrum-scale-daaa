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
# Sample Cleanup Temp Files

# unique id for the job
UNIQUE=$1

SCRIPT_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# source the defaults
source ${SCRIPT_PATH}/daaa_config ${UNIQUE}


# cleanup args given by user on panel
rm -f ${LSF_ARGS}
rm -f ${DISCOVER_SEARCH_RES}
rm -f ${DISCOVER_SEARCH_REQUEST}
rm -f ${DISCOVER_SEARCH_TO_AFM}
rm -f ${BASE_TMP}${UNIQUE}_*list_*.txt
ssh ${ESS3K_MGMT_USER}@${ESS3K_MGMT_SERVER} "rm -f ${ESS3K_MGMT_HOME_PATH}DAAA/${UNIQUE}_*list_*.txt"
ssh ${ARCHIVE_USER}@${ARCHIVE_SERVER} "rm -f ${ARCHIVE_HOME_PATH}${UNIQUE}_*list_*.txt"
