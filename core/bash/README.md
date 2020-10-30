# IBM Data Accelerator for AI and Analytics Samples

## Core code running generic workflow

Some details are logged for later review. Logfiles can be found in the user home directory in our case `/home/dean/` on the IBM Spectrum Spectrum LSF node.
The following bash scripts provide an example on how to run the generic workflow.

### daaa_config
**Location:** LSF Node:/usr/local/bin/DAAA/daaa_config

This is a config file describing the environment.

If you are planning to build a similar proof of concept environment adjust the file content to match your environment.

See the comments and samples inside the file for more details.

### DAAA.sh
**Location:** LSF Node:/usr/local/bin/DAAA/DAAA.sh

This is a sample script that gets called by IBM Spectrum LSF when a user clicked the job template `<submit>` button.

**Input Arguments:**
By the user entered OpenShift details, such as example:
`-oc_pvc=dean-workspace-pvc -oc_namespace=dean -oc_path_exec=run.sh`

and metadata the to be analyzed data must match, as example:
`-min_bicycle=900 -max_bicycle=1000`.

**Action:**
This script provides the logical flow by executing IBM Spectrum LSF sub jobs executing scripts that e.g. query discover, prepare the file lists, execute the prefetch/eviction by IBM Spectrum Scale AFM and so on.
A unique id is created that is used for log files and all sub jobs. Sub job execution is based on the successful exit of an earlier sub job (using bsub argument -w).
Input arguments are written into a file in users home directory `..._recLSFArgs.txt`.

**Output:**
File located in the users home directory holding all by the user provided details.


### searchDiscover.sh
**Location:** LSF Node:/usr/local/bin/DAAA/searchDiscover.sh

This script is called by the `DAAA.sh` script as a sub job. It prepares the search query to IBM Spectrum Discover.

The code is very depending on the used A2D2 dataset and the metadata provided with it (e.g. camera positions)

**Input Arguments:**
The by the `DAAA.sh` script generated unique id.

**Action:**
This script reformats the by the user provided metadata search details into a by IBM Spectrum Discover understandable query.

It reads the user provided details from the arguments file written by the `DAAA.sh` script.

The query arguments are constructed and provided to a `called discover_search.sh` script.

The output of the `discover_search.sh` script is reformatted and written into a file found in users home directory `..._discover_search_afm.txt`.

The path to this file is provided to the `prepFileLists.sh` script.

The provided file content looks similar to:
```
/data2/nfs/camera_lidar_semantic/20181107_133445/camera/cam_front_center/,20181107133445_camera_frontcenter_000036303.png,A2D2_NFS,NFS,resdnt
/data2/nfs/camera_lidar_semantic/20181107_133445/camera/cam_front_center/,20181107133445_camera_frontcenter_000020315.png,A2D2_NFS,NFS,resdnt
/data2/nfs/camera_lidar_semantic/20181107_133445/camera/cam_front_center/,20181107133445_camera_frontcenter_000018157.png,A2D2_NFS,NFS,resdnt
...
a2d2/,camera_lidar_semantic/20180807_145028/camera/cam_front_center/20180807145028_camera_frontcenter_000012153.png,a2d2,IBM COS,
a2d2/,camera_lidar_semantic/20180807_145028/camera/cam_front_center/20180807145028_camera_frontcenter_000027353.png,a2d2,IBM COS,
...
/ibm/fs0/archive/camera_lidar_semantic/20180807_145028/camera/cam_front_center/,20180807145028_camera_frontcenter_000063607.png,fs0,Spectrum Scale,premig
/ibm/fs0/archive/camera_lidar_semantic/20180810_142822/camera/cam_front_center/,20180810142822_camera_frontcenter_000023771.png,fs0,Spectrum Scale,premig
/ibm/fs0/archive/camera_lidar_semantic/20180810_142822/camera/cam_front_center/,20180810142822_camera_frontcenter_000022158.png,fs0,Spectrum Scale,premig
...
```

**Output:**
From IBM Spectrum Discover returned reformatted file list placed in users home directory `..._discover_search_afm.txt`.


#### discover_search.sh
**Location:** LSF Node:/usr/local/bin/DAAA/discover_search.sh

This script is a wrapper preparing for the IBM Spectrum Discover REST search call.

**Input Arguments:**
The by the `DAAA.sh` script generated unique id.

The by the `searchDiscover.sh` script generated query string.

**Action:**
It requests a token via the IBM Spectrum Discover auth REST interface for the in the config file provided user credentials.

Next it uses the received token and the provided query string to query IBM Spectrum Discover REST search interface.

The received Spectrum Discover answer is written into a file placed in users home directory `..._discover_search_res.txt`.

The by Discover replied content looks similar to:
```
{"rows": "[{\"path\":\"\\/data2\\/nfs\\/camera_lidar_semantic\\/20181108_103155\\/camera\\/cam_front_center\\/\",\"filename\":\"20181108103155_camera_frontcenter_000047224.png\",\"filetype\":\"png\",\"datasource\":\"A2D2_NFS\",\"owner\":\"0\",\"group\":\"0\",\"revision\":\"MO1\",\"site\":\"Kelsterbach\",\"platform\":\"NFS\",\"cluster\":\"192.168.1.1\",\"inode\":1084462414,\"permissions\":\"-rw-r--r--\",\"fileset\":\"NA\",\"uid\":0.0,\"gid\":0.0,\"recordversion\":\"\",\"state\":\"resdnt\",\"migloc\":\"\",\"mtime\":\"2020-09-25T20:27:37.000Z\",\"atime\":\"2020-09-25T20:27:37.000Z\",\"ctime\":\"2020-09-25T20:27:37.000Z\",\"tier\":\"system\",\"size\":3518962,\"fkey\":\"192.168.1.1A2D2_NFS1084462414\",\"collection\":null,\"temperature\":null,\"duplicate\":null,\"sizeconsumed\":3522560,\"nodename\":null,\"filespace\":null,\"mgmtclass\":null,\"imageview\":null,\"smokedetection\":null,\"location\":null,\"car\":\"278681\",\"front\":\"1\",\"side\":\"0\",\"rear\":\"0\",\"center\":\"1\",\"bicycle\":\"931\",\"pedestrian\":\"1865\",\"truck\":\"0\",\"small_vehicles\":\"0\",\"traffic_signal\":\"1019\",\"traffic_sign\":\"1049\",\"utility_vehicle\":\"0\",\"sidebars\":\"0\",\"speed_bumper\":\"0\",\"curbstone\":\"39943\",\"solid_line\":\"6121\",\"irrelevant_signs\":\"9464\",\"road_blocks\":\"0\",\"tractor\":\"0\",\"nondrivable_street\":\"48\",\"zebra_crossing\":\"0\",\"obstacles_trash\":\"3322\",\"poles\":\"12977\",\"rd_restricted_area\":\"0\",\"animals\":\"0\",\"grid_structure\":\"75747\",\"signal_corpus\":\"4558\",\"drivable_cobblestone\":\"18479\",\"electronic_traffic\":\"0\",\"slow_drive_area\":\"0\",\"nature_object\":\"168576\",\"parking_area\":\"0\",\"sidewalk\":\"110794\",\"ego_car\":\"0\",\"painted_driv_instr\":\"0\",\"traffic_guide_obj\":\"0\",\"dashed_line\":\"6209\",\"rd_normal_street\":\"459744\",\"sky\":\"930772\",\"buildings\":\"189061\",\"blurred_area\":\"0\",\"rain_dirt\":\"0\\r\",\"right_\":\"0\",\"left_\":\"0\"},
...
{\"path\":\"\\/ibm\\/fs0\\/archive\\/camera_lidar_semantic\\/20180807_145028\\/camera\\/cam_front_center\\/\",\"filename\":\"20180807145028_camera_frontcenter_000045087.png\",\"filetype\":\"png\",\"datasource\":\"fs0\",\"owner\":\"root\",\"group\":\"root\",\"revision\":\"MO1\",\"site\":\"Kelsterbach\",\"platform\":\"Spectrum Scale\",\"cluster\":\"spectrumarchive.bda.scale.com\",\"inode\":93137,\"permissions\":\"-rw-r--r--\",\"fileset\":\"archive\",\"uid\":0.0,\"gid\":0.0,\"recordversion\":\"\",\"state\":\"premig\",\"migloc\":\"1 VTAPE2L5@a171ad80-c645-4473-a886-611867897880@b3a5ec85-0825-43b3-86e3-a0909de608e1\",\"mtime\":\"2020-10-06T15:15:24.055Z\",\"atime\":\"2020-10-23T10:50:12.709Z\",\"ctime\":\"2020-10-06T15:15:24.031Z\",\"tier\":\"system\",\"size\":3683967,\"fkey\":\"spectrumarchive.bda.scale.comfs093137\",\"collection\":null,\"temperature\":null,\"duplicate\":null,\"sizeconsumed\":3686400,\"nodename\":null,\"filespace\":null,\"mgmtclass\":null,\"imageview\":null,\"smokedetection\":null,\"location\":null,\"car\":\"401427\",\"front\":\"1\",\"side\":\"0\",\"rear\":\"0\",\"center\":\"1\",\"bicycle\":\"994\",\"pedestrian\":\"1003\",\"truck\":\"0\",\"small_vehicles\":\"0\",\"traffic_signal\":\"17791\",\"traffic_sign\":\"30508\",\"utility_vehicle\":\"0\",\"sidebars\":\"0\",\"speed_bumper\":\"0\",\"curbstone\":\"48405\",\"solid_line\":\"18763\",\"irrelevant_signs\":\"12293\",\"road_blocks\":\"0\",\"tractor\":\"0\",\"nondrivable_street\":\"59667\",\"zebra_crossing\":\"0\",\"obstacles_trash\":\"3594\",\"poles\":\"50614\",\"rd_restricted_area\":\"0\",\"animals\":\"0\",\"grid_structure\":\"16407\",\"signal_corpus\":\"16481\",\"drivable_cobblestone\":\"6658\",\"electronic_traffic\":\"0\",\"slow_drive_area\":\"0\",\"nature_object\":\"458923\",\"parking_area\":\"0\",\"sidewalk\":\"37939\",\"ego_car\":\"0\",\"painted_driv_instr\":\"106\",\"traffic_guide_obj\":\"0\",\"dashed_line\":\"12041\",\"rd_normal_street\":\"330581\",\"sky\":\"544836\",\"buildings\":\"250329\",\"blurred_area\":\"0\",\"rain_dirt\":\"0\\r\",\"right_\":\"0\",\"left_\":\"0\"}]", "facet_tree": {}, "table": "metaocean_view", "query_time_secs": 5.945647, "count": 258, "doc_count": 258}
```

**Output:**
From IBM Spectrum Discover returned content stored into a file placed in users home directory `..._discover_search_res.txt`.


### prepFileLists.sh
**Location:** LSF Node:/usr/local/bin/DAAA/prepFileLists.sh

This script divides the by IBM Spectrum Discover search found files into the different attached storage systems.

**Input Arguments:**
The by the `DAAA.sh` script generated unique id.

The by the `searchDiscover.sh` script generated path to the results file in users home directory `..._discover_search_res.txt`.

The action type to generate the file lists, could be `prefetch` or `evict`.

Optional: `-arconly` option, if set only the IBM Spectrum Archive action file list is generated.


**Action:**
The Discover search results file is read line by line.

Depending on the storage system architecture, the action type and the data location, a file list is generated for every storage system and if needed for the Spectrum Archive system to handle recall or migrate actions.

For our sample we reused the prefetch lists also for the evict lists.

The generated file content looks similar to:
`..._prefetchlist_Spectrum_Scale_archive.txt`
```
/ibm/fs0/archive/camera_lidar_semantic/20180807_145028/camera/cam_front_center/20180807145028_camera_frontcenter_000063607.png
/ibm/fs0/archive/camera_lidar_semantic/20180810_142822/camera/cam_front_center/20180810142822_camera_frontcenter_000023771.png
/ibm/fs0/archive/camera_lidar_semantic/20180810_142822/camera/cam_front_center/20180810142822_camera_frontcenter_000022158.png
/ibm/fs0/archive/camera_lidar_semantic/20180810_142822/camera/cam_front_center/20180810142822_camera_frontcenter_000025399.png
...
```

`..._prefetchlist_NFS.txt`
```
/gpfs/ess3000_4M/a2d2_nfs/camera_lidar_semantic/20181108_103155/camera/cam_front_center/20181108103155_camera_frontcenter_000047224.png
/gpfs/ess3000_4M/a2d2_nfs/camera_lidar_semantic/20181204_154421/camera/cam_front_center/20181204154421_camera_frontcenter_000055356.png
/gpfs/ess3000_4M/a2d2_nfs/camera_lidar_semantic/20181107_132730/camera/cam_front_center/20181107132730_camera_frontcenter_000004482.png
/gpfs/ess3000_4M/a2d2_nfs/camera_lidar_semantic/20181107_132730/camera/cam_front_center/20181107132730_camera_frontcenter_000001674.png
...
```

`..._prefetchlist_IBM_COS.txt`
```
/gpfs/ess3000_4M/a2d2_cos/camera_lidar_semantic/20180807_145028/camera/cam_front_center/20180807145028_camera_frontcenter_000012153.png
/gpfs/ess3000_4M/a2d2_cos/camera_lidar_semantic/20180807_145028/camera/cam_front_center/20180807145028_camera_frontcenter_000027353.png
/gpfs/ess3000_4M/a2d2_cos/camera_lidar_semantic/20180807_145028/camera/cam_front_center/20180807145028_camera_frontcenter_000039699.png
/gpfs/ess3000_4M/a2d2_cos/camera_lidar_semantic/20180807_145028/camera/cam_front_center/20180807145028_camera_frontcenter_000039861.png
...
```

`..._prefetchlist_Spectrum_Scale.txt`
```
/gpfs/ess3000_4M/a2d2_arc/camera_lidar_semantic/20180807_145028/camera/cam_front_center/20180807145028_camera_frontcenter_000063607.png
/gpfs/ess3000_4M/a2d2_arc/camera_lidar_semantic/20180810_142822/camera/cam_front_center/20180810142822_camera_frontcenter_000023771.png
/gpfs/ess3000_4M/a2d2_arc/camera_lidar_semantic/20180810_142822/camera/cam_front_center/20180810142822_camera_frontcenter_000022158.png
/gpfs/ess3000_4M/a2d2_arc/camera_lidar_semantic/20180810_142822/camera/cam_front_center/20180810142822_camera_frontcenter_000025399.png
...
```

**Output:**
File lists of the to be handled files (prefetch/evict, recall/migrate) per storage system, stored in users home directory `..._<action type>list_<storage system>.txt`.


### recallArchive.sh
**Location:** LSF Node:/usr/local/bin/DAAA/recallArchive.sh

This script is called by the `DAAA.sh` script as a sub job. It triggers a recall action for data located on tape.

**Input Arguments:**
The by the `DAAA.sh` script generated unique id.

**Action:**
If during the file preparation step (see `prepFileLists.sh`) data is detected to be located on tape, a list containing the data path is generated.

If this list exists, it is copied to the archive server and an `eeadm recall` is executed.

The script returns when the recall finished.

**Output:**
none


### cacheDataIn.sh
**Location:** LSF Node:/usr/local/bin/DAAA/cacheDataIn.sh

This script is called by the `DAAA.sh` script as a sub job. It triggers the IBM Spectrum Scale prefetch process.

**Input Arguments:**
The by the `DAAA.sh` script generated unique id.

**Action:**
The during the file preparation step (see `prepFileLists.sh`) generated lists are used to execute the AFM prefetch process.

This is done by storage system and in parallel.

The called `afmExec.sh` script needs to be placed on any node of the ESS Storage Cluster and is called by this script.

Before the matching file list holding the details of the to be cached files needs to be copied to the same node and location that holds `afmExec.sh` script.

The script returns when all AFM prefetch tasks finished.

**Output:**
none


### afmExec.sh
**Location:** ESS3K_MGMT_SERVER:/root/afmExec.sh

This script is called by the `cacheDataIn.sh` and `evictDataOut.sh` scripts and is located on any node of the ESS Storage Cluster. It triggers the IBM Spectrum Scale prefetch / evict process.

**Input Arguments:**
An action, could be `prefetch` or `evict`.

The to be used filesystem, in our example `ess3000_4M`.

The to be used fileset, in our case could be `a2d2_nfs` or `a2d2_cos` or `a2d2_arc`.

The path to the file that holds the details of the to be cached files.

Provide a content file into the root directory of the provided fileset, could be `yes` or `no`.

The path the content file should be stored.

**Action:**
This script calls the IBM Spectrum Scale AFM `mmafmctl prefetch` or `mmafmctl evict` command providing the path to the file list and some further options.

See the IBM Spectrum Scale Knowledge Center documentation on what can be used for tuning.

`mmpmon` is used to watch the prefetch process and return when it finished.

If the script was called with provide a content file = yes and it is a prefetch action, it copies the file list as `content.txt` file into the provided fileset root directory. If it was for a evict action, it empties the `content.txt` file.

**Output:**
If requested, an updated `content.txt` file is copied into the provided fileset root directory.


#### evictDataOut.sh
**Location:** LSF Node:/usr/local/bin/DAAA/evictDataOut.sh

This script is called by the `DAAA.sh` script as a sub job. It triggers the IBM Spectrum Scale evict process.

**Input Arguments:**
The by the `DAAA.sh` script generated unique id.

**Action:**
It depends on the workflow which data could be evicted. For our proof of concept, we decided to evict the same data that was earlier prefetched. We use the same file lists as they got created for the caching process.

The `prepFileLists.sh` script still is called, but now with recreating the IBM Spectrum Archive lists only, as the location of the data has changed from migrated to premigrated.

The during the file preparation step (see `prepFileLists.sh`) generated lists are used to execute the AFM evict process.

This is done by storage system and in parallel.

The called `afmExec.sh` script needs to be placed on any node of the ESS Storage Cluster and is called by this script.

Before the matching file list holding the details of the to be cached files needs to be copied to the same node and location that holds `afmExec.sh` script.
The script returns when all AFM evict tasks finished.

**Output:**
none


### migrateArchive.sh
**Location:** LSF Node:/usr/local/bin/DAAA/migrateArchive.sh

This script is called by the `DAAA.sh` script as a sub job. It triggers a migrate action for data that should be migrated to tape.

**Input Arguments:**
The by the `DAAA.sh` script generated unique id.

**Action:**
If during the file preparation step (see `prepFileLists.sh`) data is detected to be moved back to tape, a list containing the data path is generated.

If this list exists, it is copied to the archive server and an `eeadm migrate` is executed.

The script returns when the migrate finished.

**Output:**
none


### cleanup.sh
**Location:** LSF Node:/usr/local/bin/DAAA/cleanup.sh

This script is called by the `DAAA.sh` script as a sub job. It removes all temporary and log files.

**Input Arguments:**
The by the `DAAA.sh` script generated unique id.

**Action:**
It removes all temporary and log files. Comment this call in `DAAA.sh` to get details of the data generated in between the different steps.

**Output:**
none
