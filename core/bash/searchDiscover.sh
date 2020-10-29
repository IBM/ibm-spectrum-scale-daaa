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
# Sample Discover Query Preparation

# unique id for the job
UNIQUE=$1

SCRIPT_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# source the defaults
source ${SCRIPT_PATH}/daaa_config ${UNIQUE}

# take the panel input and format the discover query string
QUERY_L=""
QUERY_T=""
FRONT=""
MID=""
REAR=""
LEFT=""
CENTER=""
RIGHT=""

while IFS== read -r f1 f2
do
    printf 'Option: %s, Value: %s\n' "$f1" "$f2"
    if [[ $f1 == -p_* ]]
    then
        if [[ $f1 == "-p_fl" ]]
        then
	    FRONT="front=1 and "
            LEFT="left_=1 and "
        elif [[ $f1 == "-p_fc" ]]
        then
            FRONT="front=1 and "
            CENTER="center=1 and "
        elif [[ $f1 == "-p_fr" ]]
        then
            FRONT="front=1 and "
            RIGHT="right_=1 and "
        elif [[ $f1 == "-p_ml" ]]
        then
            MID="side=1 and "
            LEFT="left_=1 and "
        elif [[ $f1 == "-p_mr" ]]
        then
            MID="side=1 and "
            RIGHT="right_=1 and "
        elif [[ $f1 == "-p_rl" ]]
        then
            REAR="rear=1 and "
            LEFT="left_=1 and "
        elif [[ $f1 == "-p_rc" ]]
        then
            REAR="rear=1 and "
            CENTER="center=1 and "
        elif [[ $f1 == "-p_rr" ]]
        then
            REAR="rear=1 and "
            RIGHT="right_=1 and "
        fi
    else
# Examples:
# -min_car=20000
# -max_car=25000
# -min_bicycle=10000
        if [[ $f1 == -min_* ]]
        then
            QUERY_T="${QUERY_T}${f1:5}>=${f2} and "
	elif [[ $f1 == -max_* ]]  
        then
            QUERY_T="${QUERY_T}${f1:5}<=${f2} and "
	fi
    fi
done <"$LSF_ARGS"

QUERY_L="${FRONT}${MID}${REAR}${LEFT}${CENTER}${RIGHT}"
QUERY="${QUERY_L}${QUERY_T}"

if [[ -n $QUERY ]]
then
    QUERY="${QUERY% and }"
fi

#echo "${QUERY}"



# run the discover query and write results to file
${SCRIPT_PATH}/discover_search.sh ${UNIQUE} "$QUERY" > ${DISCOVER_SEARCH_RES}

# reformat result
# split to lines
cut -d'{' --output-delimiter=$'\n' -f1- ${DISCOVER_SEARCH_RES} > ${BASE_TMP}${UNIQUE}_1

# read results file, skip first 3 unused lines, split the results into the by Spectrum Scale AFM needed details
i=0
while IFS= read -r p
do
  ((i <= 2 )) && ((i=i+1)) && continue  # skip first 3 lines
  ( awk -F, '{print $1 "," $2 "," $4 "," $9 "," $17}' <<< $p ) >> ${BASE_TMP}${UNIQUE}_2
done < ${BASE_TMP}${UNIQUE}_1
( sed 's/\\//g; s|["'\'']||g; s/path://g; s/filename://g; s/datasource://g; s/platform://g; s/state://g;' ${BASE_TMP}${UNIQUE}_2 ) > ${DISCOVER_SEARCH_TO_AFM}

rm -rf ${BASE_TMP}${UNIQUE}_1
rm -rf ${BASE_TMP}${UNIQUE}_2

${SCRIPT_PATH}/prepFileLists.sh -id ${UNIQUE} -files ${DISCOVER_SEARCH_TO_AFM} -type prefetch
