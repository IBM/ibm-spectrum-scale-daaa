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

## --------------------------------------------------
## Start Analytics Workload in OpenShift 
## --------------------------------------------------
## runAnalytics.sh <JOBID>
## --------------------------------------------------
## V0.6 Gero Schmidt                       2020-10-22
## --------------------------------------------------

# NAME OF SCRIPT AND OPTIONS
THIS_SCRIPT=${0##*/}
THIS_SCRIPT_OPTIONS="$@"

# FUNCTIONS
function err_exit()
{
  echo
  echo "################################################################################"
  echo "ERROR: $@ Exiting..." >&2
  echo "################################################################################"
  exit 1
}

############
##  MAIN  ##
############

## PARSE ARGUMENTS
JOBID="$1"
SCRIPT_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

## CONFIG FROM LSF PANEL (which job to run where)

## Private PVC namespace
OC_NAMESPACE=""
## Private PVC name in user namespace with program code to execute
OC_PVC=""
## Path to executable code in private user PVC
OC_PATH_EXEC=""

## SOURCE GENERAL CONFIG
source ${SCRIPT_PATH}/daaa_config

## SOURCE SCRIPT PARAMETERS
OC_PVC="$(grep "^-oc_pvc\=" "$LSF_ARGS" | cut -d= -f2)"
OC_NAMESPACE="$(grep "^-oc_namespace\=" "$LSF_ARGS" | cut -d= -f2)"
OC_PATH_EXEC="$(grep "^-oc_path_exec\=" "$LSF_ARGS" | cut -d= -f2)"

## Check prereqs
if [[ $OC_NAMESPACE == "" ]] || [[ $OC_PVC == "" ]] || [[ $OC_PATH_EXEC == "" ]]
then 
  err_exit "User namespace ($OC_NAMESPACE), user PVC ($OC_PVC), and a path ($OC_PATH_EXEC) to the executable code MUST be provided!"
fi

oc get nodes 2>&1 1>/dev/null
[[ $? != 0 ]] && err_exit "No access to OpenShift cluster!"

helm -h 2>&1 1>/dev/null
[[ $? != 0 ]] && err_exit "Helm is required to run this script!"

## OpenShift User
OC_USER=$(oc whoami)

## DEPLOY JOB AS HELM CHART
echo "### Starting analytics on OpenShift ## $(hostname -s) ## OCP user: $OC_USER ## $(date +%Y%m%d-%H:%M:%S) ###"
echo "### Job-ID: $JOBID ## Namespace: $OC_NAMESPACE ## PVC: $OC_PVC ## Executable code: $OC_PATH_EXEC ###"
helm install "daaa-$JOBID" ${SCRIPT_PATH}/helm/daaa-job --set user.pvc="$OC_PVC" --set user.command="$OC_PATH_EXEC" -n $OC_NAMESPACE
sleep 5
helm history "daaa-$JOBID"

# Wait for job to complete
oc wait --for=condition=complete --timeout=180s  "job.batch/daaa-$JOBID-daaa-job-job" -n $OC_NAMESPACE

# Wait 2nd for job to complete
oc wait --for=condition=complete --timeout=180s  "job.batch/daaa-$JOBID-daaa-job-job" -n $OC_NAMESPACE

# Get logs from completed job
oc logs job.batch/daaa-$JOBID-daaa-job-job -n $OC_NAMESPACE

# Delete all daaa resources
helm delete daaa-$JOBID -n $OC_NAMESPACE

# Check all resources are gone
oc get pods -n $OC_NAMESPACE
oc get pvc -n $OC_NAMESPACE
oc get pv | grep "daaa\|NAME"

echo "### Completed analytics on OpenShift ## $(hostname -s) ## $(date +%Y%m%d-%H:%M:%S) ###"
exit 0

