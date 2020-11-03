# IBM Data Accelerator for AI and Analytics Samples

## Core code running generic workflow

The following python code provides an example on how to run the generic workflow.

### DAAA.ini
**Location:** Scale client node:/usr/local/bin/DAAApy/DAAA.ini

This is a config file describing the environment.

If you are planning to build a similar proof of concept environment adjust the file content to match your environment.

See the comments and samples inside the file for more details.

### DAAA.py
**Location:** Scale client node:/usr/local/bin/DAAApy/DAAA.py

This is sample code that gets called by the `runDAAAA.py` code.

It has multiple different functions that are shortly explained. It provides each step in it's own function e.g. query discover, recall and cache data, ... .

They match in general the functionality that is provided by the [bash](../bash/) scripts.


**getStatus**
Provides details such as the `uniqueId`, `lastQuery`, `nextAction`, `status`, `availableData`.

If in the `DAAA.ini`file `[general] print_status_always` is set to `True`, with all external functions the status is printed at the end.

Sample output:
```
{
    "uniqueId": "twiefoqzxb_",
    "lastQuery": [
        "front=1",
        "center=1",
        "bicycle>=900",
        "bicycle<=1000"
    ],
    "nextAction": "prefetch",
    "status": "done",
    "availableData": {
        "NFS": 24,
        "IBM COS": 114,
        "Spectrum Scale": 14
    }
}
```


**getConfig**
Prints the configuration as provided in the `DAAA.ini` file.

Sample output:
```
=== general ===
content_file=yes
print_status_always=True

=== discover ===
rest_user=sdadmin
rest_password=Passw0rd
rest_server=192.168.1.230
connection_platform_nfs=NFS
connection_platform_obj=IBM COS
connection_platform_arc=Spectrum Scale
connection_datasource_nfs=A2D2_NFS
connection_datasource_obj=a2d2
connection_datasource_arc=fs0
...
```


**getFileLists**
Prints the per storage system available and by the IBM Spectrum Scale for the search replied file lists.

Provide the storage system (as replied by `getStatus`) in an array to get certain results or leave it empty to get a list of all.

Sample output:
```
NFS
['/gpfs/ess3000_4M/a2d2_nfs/camera_lidar_semantic/20181108_103155/camera/cam_front_center/20181108103155_camera_frontcenter_000047224.png', '/gpfs/ess3000_4M/a2d2_nfs/camera_lidar_semantic/20181107_132300/camera/cam_front_center/20181107132300_camera_frontcenter_000004913.png', '/gpfs/ess3000_4M/a2d2_nfs/camera_lidar_semantic/20181107_132730/camera/cam_front_center/20181107132730_camera_frontcenter_000001097.png', 
...
'/gpfs/ess3000_4M/a2d2_nfs/camera_lidar_semantic/20181107_132730/camera/cam_front_center/20181107132730_camera_frontcenter_000001508.png']
IBM COS
['/gpfs/ess3000_4M/a2d2_cos/camera_lidar_semantic/20180925_124435/camera/cam_front_center/20180925124435_camera_frontcenter_000022741.png', '/gpfs/ess3000_4M/a2d2_cos/camera_lidar_semantic/20181016_125231/camera/cam_front_center/20181016125231_camera_frontcenter_000024958.png', '/gpfs/ess3000_4M/a2d2_cos/camera_lidar_semantic/20181016_125231/camera/cam_front_center/20181016125231_camera_frontcenter_000069123.png', 
...
'/gpfs/ess3000_4M/a2d2_cos/camera_lidar_semantic/20180925_135056/camera/cam_front_center/20180925135056_camera_frontcenter_000034248.png']
Spectrum Scale
['/gpfs/ess3000_4M/a2d2_arc/camera_lidar_semantic/20180807_145028/camera/cam_front_center/20180807145028_camera_frontcenter_000063615.png', '/gpfs/ess3000_4M/a2d2_arc/camera_lidar_semantic/20180807_145028/camera/cam_front_center/20180807145028_camera_frontcenter_000012153.png', '/gpfs/ess3000_4M/a2d2_arc/camera_lidar_semantic/20180810_142822/camera/cam_front_center/20180810142822_camera_frontcenter_000010461.png', 
...
'/gpfs/ess3000_4M/a2d2_arc/camera_lidar_semantic/20180810_142822/camera/cam_front_center/20180810142822_camera_frontcenter_000025399.png']
```


**searchDiscover**
Queries the IBM Spectrum Discover REST interface with given tags.

The last provided query is stored, so that a 2nd query with the same tags can be called without providing the details again.

The query results are stored in an array and can be requested with the `getFileLists` function.

The `action` argument (`prefetch` or `evict`) is needed to decide on Tape archive / migration actions.

The `arconly` argument (`True` or `False`) is optional. When set to `True`, it triggers only Tape archive / migration file list updates. The earlier generated AFM cache / evict lists will not be changed.


**recallArchive**
Recalls the provided files from Tape via IBM Spectrum Archive if needed.

The file list is generated `/tmp/<unique_id>_recall.txt` and is copied to the Archive server and a recall is triggered.


**cacheDataIn**
Calls the `afmExec.sh` script on the IBM Spectrum Scale client node. It triggers the Active File Management feature to prefetch the data.

The file list is generated `/tmp/<unique_id>_prefetch_<type>.txt` and is copied to the Scale client node and a prefetch is triggered.


**runAnalytics**
Placeholder, run any of your analytic code here.


**evictDataOut**
Calls the `afmExec.sh` script on the IBM Spectrum Scale client node. It triggers the Active File Management feature to evict the data.

The file list is generated `/tmp/<unique_id>_evict_<type>.txt` and is copied to the Scale client node and an evict is triggered.


**migrateArchive**
Migrates the provided files to Tape via IBM Spectrum Archive if needed.

The file list is generated `/tmp/<unique_id>_migrate.txt` and is copied to the Archive server and a migrate is triggered.


**cleanup**
Removes all temporary generated files.


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

