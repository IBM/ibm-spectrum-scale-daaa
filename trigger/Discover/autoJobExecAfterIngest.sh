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
# Sample Workload Execution after Data Ingest

# platform ingested
PLATFORM=$1

# data source ingested
DATA_SOURCE=$2

#echo "${PLATFORM} ${DATA_SOURCE}"

# trigger a predefined job
if [[ "${PLATFORM}" == "IBM_COS" && "${DATA_SOURCE}" == "a2d2" ]]; then
    /usr/local/bin/DAAA/DAAA.sh -oc_pvc=dean-workspace-pvc -oc_namespace=dean -oc_path_exec=run.sh -min_bicycle=900 -max_bicycle=1000
fi
