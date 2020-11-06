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
# Sample Discover Search Execution

# unique id for the job
UNIQUE=$1

SCRIPT_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# source the defaults
source ${SCRIPT_PATH}/daaa_config ${UNIQUE}

# get auth token for the REST API
TOKEN=$(curl -k -u ${DISCOVER_REST_USER}:${DISCOVER_REST_PASSWORD} https://${DISCOVER_REST_SERVER}/auth/v1/token -I |awk '/X-Auth-Token/ {print $2}')
echo $TOKEN

QUERY_JSON='{"query": "'$2'", "filters": [], "group_by": [], "sort_by": [], "limit": 100000}'
echo "https://${DISCOVER_REST_SERVER}/db2whrest/v1/search -X POST -d '${QUERY_JSON}' -H 'Content-Type: application/json'" > ${DISCOVER_SEARCH_REQUEST}
curl -k -H "Authorization: Bearer ${TOKEN}" https://${DISCOVER_REST_SERVER}/db2whrest/v1/search -X POST -d "${QUERY_JSON}" -H 'Content-Type: application/json'

