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

# ----------------------------------------------------------
# Start Analytics Workload in OpenShift for DAAA Workflow 
# ----------------------------------------------------------
# Run: runAnalytics.sh <JOBID>
# ----------------------------------------------------------
# Input:
#    (1) Reads DAAA config from "daaa_config" file
#    (2) Reads job parameters from config file in
#        user's home directory on the LSF node
#        e.g. 
#        -oc_namespace=dean
#        -oc_pvc=dean-workspace-pvc
#        -oc_path_exec=run.sh
# ----------------------------------------------------------
# Requirements:
# - oc (OpenShift client)
# - helm (Helm binary)
# - .kube/config to access OpenShift cluster as system:admin
# ----------------------------------------------------------
# In this sample workflow the DAAA job is temporarily
# creating new persistent volumes (PVs) with access to the
# prefetched data from the DAAA pipeline for the duration of
# the job. After the job has finished the PVs are removed. 
# For the PV creation system:admin privileges are required.
# The workload is executed in the user's namespace as a 
# Kubernetes job which runs in a generic user context 
# with a generic user ID assigned by OpenShift.
# ----------------------------------------------------------

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

## USER namespace to execute DAAA job in
OC_NAMESPACE=""
## PVC name in USER namespace with program code to execute
OC_PVC=""
## Path to executable code in above PVC in USER namespace
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

if ! oc get nodes 2>&1 1>/dev/null
then
  err_exit "No access to OpenShift cluster!"
fi

if ! helm -h 2>&1 1>/dev/null
then
  err_exit "Helm is required to run this script!"
fi

## OpenShift User
OC_USER=$(oc whoami)

## DEPLOY JOB AS HELM CHART
echo
echo "### Starting analytics on OpenShift ## $(hostname -s) ## OCP user: $OC_USER ## $(date +%Y%m%d-%H:%M:%S) ###"
echo "### Job-ID: $JOBID ## Namespace: $OC_NAMESPACE ## PVC: $OC_PVC ## Executable code: $OC_PATH_EXEC ###"
helm install "daaa-$JOBID" ${SCRIPT_PATH}/helm/daaa --set user.pvc="$OC_PVC" --set user.command="$OC_PATH_EXEC" -n $OC_NAMESPACE
sleep 5
helm history "daaa-$JOBID"

# Check all resources are created
sleep 15
echo
echo "### RESOURCES DEPLOYED ## $(hostname -s) ## OCP user: $OC_USER ## $(date +%Y%m%d-%H:%M:%S) ###"
echo "### Job-ID: $JOBID ## Namespace: $OC_NAMESPACE ## PVC: $OC_PVC ## Executable code: $OC_PATH_EXEC ###"
oc get pvc -n $OC_NAMESPACE
oc get pv | grep "daaa\|NAME"
oc get jobs -n $OC_NAMESPACE
oc get pods -n $OC_NAMESPACE

# Wait for job to complete
echo
echo "### WAITING FOR JOB TO COMPLETE ## $(hostname -s) ## OCP user: $OC_USER ## $(date +%Y%m%d-%H:%M:%S) ###"
echo "### Job-ID: $JOBID ## Namespace: $OC_NAMESPACE ## PVC: $OC_PVC ## Executable code: $OC_PATH_EXEC ###"
oc wait --for=condition=complete --timeout=180s  "job.batch/daaa-$JOBID-job" -n $OC_NAMESPACE
# Wait 2nd for job to complete
oc wait --for=condition=complete --timeout=180s  "job.batch/daaa-$JOBID-job" -n $OC_NAMESPACE

# Get logs from completed job
echo
echo "### LOG OUTPUT OF COMPLETED JOB ## --- BEGIN --- ## $(hostname -s) ## OCP user: $OC_USER ## $(date +%Y%m%d-%H:%M:%S) ###"
echo "### Job-ID: $JOBID ## Namespace: $OC_NAMESPACE ## PVC: $OC_PVC ## Executable code: $OC_PATH_EXEC ###"
oc logs job.batch/daaa-$JOBID-job -n $OC_NAMESPACE
echo "### LOG OUTPUT OF COMPLETED JOB ## --- END --- ## $(hostname -s) ## OCP user: $OC_USER ## $(date +%Y%m%d-%H:%M:%S) ###"
echo

# Delete all daaa resources
helm delete daaa-$JOBID -n $OC_NAMESPACE

# Check all resources are removed
sleep 10
echo
echo "### CLEAN UP AFTER JOB COMPLETION ## $(hostname -s) ## OCP user: $OC_USER ## $(date +%Y%m%d-%H:%M:%S) ###"
echo "### Job-ID: $JOBID ## Namespace: $OC_NAMESPACE ## PVC: $OC_PVC ## Executable code: $OC_PATH_EXEC ###"
oc get pvc -n $OC_NAMESPACE
oc get pv | grep "daaa\|NAME"
oc get jobs -n $OC_NAMESPACE
oc get pods -n $OC_NAMESPACE

echo
echo "### Completed analytics on OpenShift ## $(hostname -s) ## $(date +%Y%m%d-%H:%M:%S) ###"
exit 0
