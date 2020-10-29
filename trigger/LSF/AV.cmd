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

UNIQUE=`date +%Y%m%d_%Hh%Mm%S`
JOB_NAME="AV_${UNIQUE}"

if [ "x$QUEUE" != "x" ]; then
        SUB_QUEUE_OPT="-q $QUEUE"
else
        SUB_QUEUE_OPT=""
fi

if [ "x$OC_PVC" != "x" ]; then
   arr_options+=( "-oc_pvc=$OC_PVC" )
fi
if [ "x$OC_NAMESPACE" != "x" ]; then
   arr_options+=( "-oc_namespace=$OC_NAMESPACE" )
fi
if [ "x$OC_PATH_EXEC" != "x" ]; then
   arr_options+=( "-oc_path_exec=$OC_PATH_EXEC" )
fi

#########################
if [ "x$MIN_FILENAME" != "x" ]; then
   arr_options+=( "-min_filename=$MIN_FILENAME" )
fi
if [ "x$MAX_FILENAME" != "x" ]; then
   arr_options+=( "-max_filename=$MAX_FILENAME" )
fi
if [ "x$P_FL" != "xno" ]; then
   arr_options+=( "-p_fl=$P_FL" )
fi
if [ "x$P_FC" != "xno" ]; then
   arr_options+=( "-p_fc=$P_FC" )
fi
if [ "x$P_FR" != "xno" ]; then
   arr_options+=( "-p_fr=$P_FR" )
fi
if [ "x$P_ML" != "xno" ]; then
   arr_options+=( "-p_ml=$P_ML" )
fi
if [ "x$P_MR" != "xno" ]; then
   arr_options+=( "-p_mr=$P_MR" )
fi
if [ "x$P_RL" != "xno" ]; then
   arr_options+=( "-p_rl=$P_RL" )
fi
if [ "x$P_RC" != "xno" ]; then
   arr_options+=( "-p_rc=$P_RC" )
fi
if [ "x$P_RR" != "xno" ]; then
   arr_options+=( "-p_rr=$P_RR" )
fi

#########################
if [ "x$MIN_CAR" != "x" ]; then
   arr_options+=( "-min_car=$MIN_CAR" )
fi
if [ "x$MAX_CAR" != "x" ]; then
   arr_options+=( "-max_car=$MAX_CAR" )
fi
if [ "x$MIN_BICYCLE" != "x" ]; then
   arr_options+=( "-min_bicycle=$MIN_BICYCLE" )
fi
if [ "x$MAX_BICYCLE" != "x" ]; then
   arr_options+=( "-max_bicycle=$MAX_BICYCLE" )
fi
if [ "x$MIN_PEDESTRIAN" != "x" ]; then
   arr_options+=( "-min_pedestrian=$MIN_PEDESTRIAN" )
fi
if [ "x$MAX_PEDESTRIAN" != "x" ]; then
   arr_options+=( "-max_pedestrian=$MAX_PEDESTRIAN" )
fi
if [ "x$MIN_TRUCK" != "x" ]; then
   arr_options+=( "-min_truck=$MIN_TRUCK" )
fi
if [ "x$MAX_TRUCK" != "x" ]; then
   arr_options+=( "-max_truck=$MAX_TRUCK" )
fi
if [ "x$MIN_SMALL_VEHICLES" != "x" ]; then
   arr_options+=( "-min_small_vehicles=$MIN_SMALL_VEHICLES" )
fi
if [ "x$MAX_SMALL_VEHICLES" != "x" ]; then
   arr_options+=( "-max_small_vehicles=$MAX_SMALL_VEHICLES" )
fi
if [ "x$MIN_TRAFFIC_SIGNAL" != "x" ]; then
   arr_options+=( "-min_traffic_signal=$MIN_TRAFFIC_SIGNAL" )
fi
if [ "x$MAX_TRAFFIC_SIGNAL" != "x" ]; then
   arr_options+=( "-max_traffic_signal=$MAX_TRAFFIC_SIGNAL" )
fi
if [ "x$MIN_TRAFFIC_SIGN" != "x" ]; then
   arr_options+=( "-min_traffic_sign=$MIN_TRAFFIC_SIGN" )
fi
if [ "x$MAX_TRAFFIC_SIGN" != "x" ]; then
   arr_options+=( "-max_traffic_sign=$MAX_TRAFFIC_SIGN" )
fi
if [ "x$MIN_UTILITY_VEHICLE" != "x" ]; then
   arr_options+=( "-min_utility_vehicle=$MIN_UTILITY_VEHICLE" )
fi
if [ "x$MAX_UTILITY_VEHICLE" != "x" ]; then
   arr_options+=( "-max_utility_vehicle=$MAX_UTILITY_VEHICLE" )
fi
if [ "x$MIN_SIDEBARS" != "x" ]; then
   arr_options+=( "-min_sidebars=$MIN_SIDEBARS" )
fi
if [ "x$MAX_SIDEBARS" != "x" ]; then
   arr_options+=( "-max_sidebars=$MAX_SIDEBARS" )
fi
if [ "x$MIN_SPEED_BUMPER" != "x" ]; then
   arr_options+=( "-min_speed_bumper=$MIN_SPEED_BUMPER" )
fi
if [ "x$MAX_SPEED_BUMPER" != "x" ]; then
   arr_options+=( "-max_speed_bumper=$MAX_SPEED_BUMPER" )
fi
if [ "x$MIN_CURBSTONE" != "x" ]; then
   arr_options+=( "-min_curbstone=$MIN_CURBSTONE" )
fi
if [ "x$MAX_CURBSTONE" != "x" ]; then
   arr_options+=( "-max_curbstone=$MAX_CURBSTONE" )
fi
if [ "x$MIN_SOLID_LINE" != "x" ]; then
   arr_options+=( "-min_solid_line=$MIN_SOLID_LINE" )
fi
if [ "x$MAX_SOLID_LINE" != "x" ]; then
   arr_options+=( "-max_solid_line=$MAX_SOLID_LINE" )
fi
if [ "x$MIN_IRRELEVANT_SIGNS" != "x" ]; then
   arr_options+=( "-min_irrelevant_signs=$MIN_IRRELEVANT_SIGNS" )
fi
if [ "x$MAX_IRRELEVANT_SIGNS" != "x" ]; then
   arr_options+=( "-max_irrelevant_signs=$MAX_IRRELEVANT_SIGNS" )
fi
if [ "x$MIN_ROAD_BLOCKS" != "x" ]; then
   arr_options+=( "-min_road_blocks=$MIN_ROAD_BLOCKS" )
fi
if [ "x$MAX_ROAD_BLOCKS" != "x" ]; then
   arr_options+=( "-max_road_blocks=$MAX_ROAD_BLOCKS" )
fi
if [ "x$MIN_TRACTOR" != "x" ]; then
   arr_options+=( "-min_tractor=$MIN_TRACTOR" )
fi
if [ "x$MAX_TRACTOR" != "x" ]; then
   arr_options+=( "-max_tractor=$MAX_TRACTOR" )
fi
if [ "x$MIN_NONDRIVABLE_STREET" != "x" ]; then
   arr_options+=( "-min_nondrivable_street=$MIN_NONDRIVABLE_STREET" )
fi
if [ "x$MAX_NONDRIVABLE_STREET" != "x" ]; then
   arr_options+=( "-max_nondrivable_street=$MAX_NONDRIVABLE_STREET" )
fi
if [ "x$MIN_ZEBRA_CROSSING" != "x" ]; then
   arr_options+=( "-min_zebra_crossing=$MIN_ZEBRA_CROSSING" )
fi
if [ "x$MAX_ZEBRA_CROSSING" != "x" ]; then
   arr_options+=( "-max_zebra_crossing=$MAX_ZEBRA_CROSSING" )
fi
if [ "x$MIN_OBSTACLES_TRASH" != "x" ]; then
   arr_options+=( "-min_obstacles_trash=$MIN_OBSTACLES_TRASH" )
fi
if [ "x$MAX_OBSTACLES_TRASH" != "x" ]; then
   arr_options+=( "-max_obstacles_trash=$MAX_OBSTACLES_TRASH" )
fi
if [ "x$MIN_POLES" != "x" ]; then
   arr_options+=( "-min_poles=$MIN_POLES" )
fi
if [ "x$MAX_POLES" != "x" ]; then
   arr_options+=( "-max_poles=$MAX_POLES" )
fi
if [ "x$MIN_RD_RESTRICTED_AREA" != "x" ]; then
   arr_options+=( "-min_rd_restricted_area=$MIN_RD_RESTRICTED_AREA" )
fi
if [ "x$MAX_RD_RESTRICTED_AREA" != "x" ]; then
   arr_options+=( "-max_rd_restricted_area=$MAX_RD_RESTRICTED_AREA" )
fi
if [ "x$MIN_ANIMALS" != "x" ]; then
   arr_options+=( "-min_animals=$MIN_ANIMALS" )
fi
if [ "x$MAX_ANIMALS" != "x" ]; then
   arr_options+=( "-max_animals=$MAX_ANIMALS" )
fi
if [ "x$MIN_GRID_STRUCTURE" != "x" ]; then
   arr_options+=( "-min_grid_structure=$MIN_GRID_STRUCTURE" )
fi
if [ "x$MAX_GRID_STRUCTURE" != "x" ]; then
   arr_options+=( "-max_grid_structure=$MAX_GRID_STRUCTURE" )
fi
if [ "x$MIN_SIGNAL_CORPUS" != "x" ]; then
   arr_options+=( "-min_signal_corpus=$MIN_SIGNAL_CORPUS" )
fi
if [ "x$MAX_SIGNAL_CORPUS" != "x" ]; then
   arr_options+=( "-max_signal_corpus=$MAX_SIGNAL_CORPUS" )
fi
if [ "x$MIN_DRIVABLE_COBBLESTONE" != "x" ]; then
   arr_options+=( "-min_drivable_cobblestone=$MIN_DRIVABLE_COBBLESTONE" )
fi
if [ "x$MAX_DRIVABLE_COBBLESTONE" != "x" ]; then
   arr_options+=( "-max_drivable_cobblestone=$MAX_DRIVABLE_COBBLESTONE" )
fi
if [ "x$MIN_ELECTRONIC_TRAFFIC" != "x" ]; then
   arr_options+=( "-min_electronic_traffic=$MIN_ELECTRONIC_TRAFFIC" )
fi
if [ "x$MAX_ELECTRONIC_TRAFFIC" != "x" ]; then
   arr_options+=( "-max_electronic_traffic=$MAX_ELECTRONIC_TRAFFIC" )
fi
if [ "x$MIN_SLOW_DRIVE_AREA" != "x" ]; then
   arr_options+=( "-min_slow_drive_area=$MIN_SLOW_DRIVE_AREA" )
fi
if [ "x$MAX_SLOW_DRIVE_AREA" != "x" ]; then
   arr_options+=( "-max_slow_drive_area=$MAX_SLOW_DRIVE_AREA" )
fi
if [ "x$MIN_NATURE_OBJECT" != "x" ]; then
   arr_options+=( "-min_nature_object=$MIN_NATURE_OBJECT" )
fi
if [ "x$MAX_NATURE_OBJECT" != "x" ]; then
   arr_options+=( "-max_nature_object=$MAX_NATURE_OBJECT" )
fi
if [ "x$MIN_PARKING_AREA" != "x" ]; then
   arr_options+=( "-min_parking_area=$MIN_PARKING_AREA" )
fi
if [ "x$MAX_PARKING_AREA" != "x" ]; then
   arr_options+=( "-max_parking_area=$MAX_PARKING_AREA" )
fi
if [ "x$MIN_SIDEWALK" != "x" ]; then
   arr_options+=( "-min_sidewalk=$MIN_SIDEWALK" )
fi
if [ "x$MAX_SIDEWALK" != "x" ]; then
   arr_options+=( "-max_sidewalk=$MAX_SIDEWALK" )
fi
if [ "x$MIN_EGO_CAR" != "x" ]; then
   arr_options+=( "-min_ego_car=$MIN_EGO_CAR" )
fi
if [ "x$MAX_EGO_CAR" != "x" ]; then
   arr_options+=( "-max_ego_car=$MAX_EGO_CAR" )
fi
if [ "x$MIN_PAINTED_DRIV_INSTR" != "x" ]; then
   arr_options+=( "-min_painted_driv_instr=$MIN_PAINTED_DRIV_INSTR" )
fi
if [ "x$MAX_PAINTED_DRIV_INSTR" != "x" ]; then
   arr_options+=( "-max_painted_driv_instr=$MAX_PAINTED_DRIV_INSTR" )
fi
if [ "x$MIN_TRAFFIC_GUIDE_OBJ" != "x" ]; then
   arr_options+=( "-min_traffic_guide_obj=$MIN_TRAFFIC_GUIDE_OBJ" )
fi
if [ "x$MAX_TRAFFIC_GUIDE_OBJ" != "x" ]; then
   arr_options+=( "-max_traffic_guide_obj=$MAX_TRAFFIC_GUIDE_OBJ" )
fi
if [ "x$MIN_DASHED_LINE" != "x" ]; then
   arr_options+=( "-min_dashed_line=$MIN_DASHED_LINE" )
fi
if [ "x$MAX_DASHED_LINE" != "x" ]; then
   arr_options+=( "-max_dashed_line=$MAX_DASHED_LINE" )
fi
if [ "x$MIN_RD_NORMAL_STREET" != "x" ]; then
   arr_options+=( "-min_rd_normal_street=$MIN_RD_NORMAL_STREET" )
fi
if [ "x$MAX_RD_NORMAL_STREET" != "x" ]; then
   arr_options+=( "-max_rd_normal_street=$MAX_RD_NORMAL_STREET" )
fi
if [ "x$MIN_SKY" != "x" ]; then
   arr_options+=( "-min_sky=$MIN_SKY" )
fi
if [ "x$MAX_SKY" != "x" ]; then
   arr_options+=( "-max_sky=$MAX_SKY" )
fi
if [ "x$MIN_BUILDINGS" != "x" ]; then
   arr_options+=( "-min_buildings=$MIN_BUILDINGS" )
fi
if [ "x$MAX_BUILDINGS" != "x" ]; then
   arr_options+=( "-max_buildings=$MAX_BUILDINGS" )
fi
if [ "x$MIN_BLURRED_AREA" != "x" ]; then
   arr_options+=( "-min_blurred_area=$MIN_BLURRED_AREA" )
fi
if [ "x$MAX_BLURRED_AREA" != "x" ]; then
   arr_options+=( "-max_blurred_area=$MAX_BLURRED_AREA" )
fi
if [ "x$MIN_RAIN_DIRT" != "x" ]; then
   arr_options+=( "-min_rain_dirt=$MIN_RAIN_DIRT" )
fi
if [ "x$MAX_RAIN_DIRT" != "x" ]; then
   arr_options+=( "-max_rain_dirt=$MAX_RAIN_DIRT" )
fi


############################
if [ "x$TAGS" != "x" ]; then
   arr_options+=( "-tags=$TAGS" )
fi

printf '%s\n' "${arr_options[@]}" > /home/dean/file.txt

argsOut=$( IFS=$' '; echo "${arr_options[*]}" )
JOB_RESULT=`/bin/sh -c "bsub -J ${JOB_NAME} ${SUB_QUEUE_OPT} "/usr/local/bin/DAAA/DAAA.sh" ${argsOut} 2>&1"`

${GUI_CONFDIR}/application/job-result.sh
