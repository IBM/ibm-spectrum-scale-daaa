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
# Sample Archive Migrate Execution

# unique id for the job
UNIQUE=$1

SCRIPT_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# source the defaults
source ${SCRIPT_PATH}/daaa_config ${UNIQUE}

if test -e ${BASE_TMP}${UNIQUE}_evictlist_Spectrum_Scale_archive.txt; then
    scp ${BASE_TMP}${UNIQUE}_evictlist_Spectrum_Scale_archive.txt ${ARCHIVE_USER}@${ARCHIVE_SERVER}:${ARCHIVE_HOME_PATH}
    #ssh -t ${ARCHIVE_USER}@${ARCHIVE_SERVER} ${ARCHIVE_SUDO}"${ARCHIVE_HOME_PATH}migrate.sh -files ${ARCHIVE_HOME_PATH}${UNIQUE}_evictlist_Spectrum_Scale_archive.txt"
    ssh -t ${ARCHIVE_USER}@${ARCHIVE_SERVER} ${ARCHIVE_SUDO}"/opt/ibm/ltfsee/bin/eeadm migrate ${ARCHIVE_HOME_PATH}${UNIQUE}_evictlist_Spectrum_Scale_archive.txt -p pool1"
fi
