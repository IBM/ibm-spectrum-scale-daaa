# IBM Data Accelerator for AI and Analytics Samples

## Workload triggers

Scripts that trigger the workflow can be found in the trigger directory.

### LSF Workload trigger
The following scripts (located in the LSF directory) provide examples to generate the Autonomous Vehicle use case job template and have it trigger the `DAAA.sh` script.

#### AV.xml
**Location:** LSF Node:/opt/ibm/lsfsuite/ext/gui/conf/application/published/AV/AV.xml
This xml file is used to build the IBM Spectrum LSF job submission template.
Follow the "IBM Spectrum LSF Application Center" "Submission (Application) templates" guidance to create a similar template.
This template is tailored to an Autonomous Vehicle workload and a dataset used as described in the RedPaper.

#### AV.cmd
**Location:** LSF Node:/opt/ibm/lsfsuite/ext/gui/conf/application/published/AV/AV.cmd
This script is called when the user pressed the job submit button.
It is tailored to the AV template and takes the by the user entered details and reformats those to provide it to the `DAAA.sh` script which is called.


### Discover new object trigger
The following scripts (located in the Discover directory) provide examples on how to monitor new data events published into IBM Spectrum Scale Discover Kafka queue.

#### newDataWriter.sh
**Location:** DISCOVER_REST_SERVER:/home/moadmin/newDataWriter.sh
This script continuously listens to the IBM Spectrum Discover Kafka queue that is used to inform Discover about metadata updates.

**Input Arguments:**
none

**Action:**
New events are written into file `/home/moadmin/kafkaevents`. The changes are monitored and handled by the `newDataListener.sh` script.

**Output:**
none


#### newDataListener.sh
**Location:** DISCOVER_REST_SERVER:/home/moadmin/newDataListener.sh
This script continuously monitors updates of the `/home/moadmin/kafkaevents` file, which holds new received events coming from the IBM Spectrum Discover Kafka queue that is used to inform Discover about metadata updates.

**Input Arguments:**
Minutes a file content did not change and now should be handled
The file to monitor

**Action:**
Command `file -mmin` is used to detect files that did not change for a given time.
If earlier an `Object:Write` event was received and now the file did not change for the given time, script `autoJobExecAfterIngest.sh` on the LSF node is called to trigger a predefined workload.

**Output:**
none


#### autoJobExecAfterIngest.sh
**Location:** LSF Node:/usr/local/bin/DAAA/autoJobExecAfterIngest.sh
This script is called by the `newDataListener.sh` script. It triggers a predefined workload.

**Input Arguments:**
The storage platform of the received event, in our example `IBM_COS`
The data source of the received event, in our case bucket `a2d2`

**Action:**
This script triggers a predefined workload by calling the `DAAA.sh` script with predefined options.

**Output:**
none
