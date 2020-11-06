# IBM Data Accelerator for AI and Analytics Samples

## Workload execution

Here you can find example scripts to execute a job on the data that was preloaded 
into the *high performance smart storage tier* on IBM Spectrum Scale through 
the DAAA pipeline.
 
## OpenShift

In this example of a DAAA workflow we run the deployment of the user's batch job 
in OpenShift in the context of the *system:admin* user because the creation of the 
*persistent volumes* (PVs) to access the preloaded data in the 
*high performance smart storage tier* requires the *system:admin* context. 

The *persistent volume claims* (PVCs) as well as the *pod* that is running the workload 
are bound to the user's namespace. The workload is started as a Kubernetes job to ensure that the workload is actually 
executed in a user context with an arbitrary user ID determined by OpenShift, 
i.e. the workload is not executed in a system:admin or privileged context.

The workload execution task in our DAAA workflow example comprises two parts:

 - The *runAnalytics.sh* script that is executed by the DAAA pipeline.
 - A Helm chart named *daaa* with the OpenShift/Kubernetes resources that need to be created.

#### runAnalytics.sh

**Location:** LSF Node:/usr/local/bin/DAAA/runAnalytics.sh

**Input Arguments:**

1. Reads DAAA config from "daaa_config" file
2. Reads DAAA job parameters from config file in user's home directory on the LSF node, e.g.
```
  -oc_namespace=dean : The user's namespace to execute the workload in.    
  -oc_pvc=dean-workspace-pvc : The user's *persistent volume claim* (PVC) which binds to the user's *persistent volume* (PV) that holds the executable code for the workload.
  -oc_path_exec=run.sh : The path to the executable code in the user's *persistent volume claim* (PVC) to run the scheduled workload.
```

**Action:**

In this sample workflow script the DAAA job is temporarily
creating new *persistent volumes* (PVs) with access to the
data provided by the DAAA pipeline for the duration of
the job. After the job has finished the PVs are removed. 
For the PV creation *system:admin* privileges are required.
The workload is executed in the user's namespace as a 
Kubernetes job which runs in a generic user context 
with a generic user ID assigned by OpenShift.
The executable code for running the AI workload is located 
in the user's individual workspace, i.e. an existing *persistent volume* (PV)
bound to the user's namespace by a *persistent volume claim* (PVC).  
All OpenShift/Kubernetes resources are deployed through
a Helm chart in *helm/daaa*.

**Output:**

The scripts outputs a log of all tasks that are performed to standard out,
including the log of the Kubernetes job.

The trained model of the AI workload is written to the user's local 
workspace (/workspace) and also exported
to the shared models directory (/models) hosted on COS for later use 
in an AI model deployment pipeline.


#### helm/daaa

The Helm chart can be deployed as follows:

    # helm install "daaa-$JOBID" ${SCRIPT_PATH}/helm/daaa --set user.pvc="$OC_PVC" --set user.command="$OC_PATH_EXEC" -n $OC_NAMESPACE

The Helm chart deployment can be removed as follows:

    # helm delete "daaa-$JOBID" 

**Location:** LSF Node:/usr/local/bin/DAAA/helm/daaa

**Input Arguments:**

At minimum the folowing parameters are required:

1. -n $OC_NAMESPACE : The user's namespace to execute the workload in.    
2. --set user.pvc="$OC_PVC" : The user's *persistent volume claim* (PVC) which binds to the user's *persistent volume* (PV) that holds the executable code for the workload.
3. --set user.command="$OC_PATH_EXEC" : The path to the executable code in the user's *persistent volume claim* (PVC) to run the scheduled workload.

All default values and other variables used in the templates are defined in the *daaa/values.yaml* file.

**Action:**

The Helm chart creates the *persistent volumes* which provide access
to the four filesets (a2d2_cos, a2d2_nfs, a2d2_arc, models) returned
by the DAAA workflow. It then binds these PVs to the user's namespace
through a *persistent volume claim* (PVC). Kubernetes *labels* are used 
to match the correct PV with the intended data to each PVC.
Then a Kubernets job is run which mounts all these PVs into a pod 
in order to execute the user's workload. The user's code (user.command) 
for running the workload is stored on an additional (private) PV (user.pvc)
mounted at /workspace. The pod is executed through a Kubernetes job 
which guarantees that the pod is executed in an arbitrary 
user context in the user namespace (determined by OpenShift) and not running
in a privileged context of the system:admin.  
 
**Output:**

Nothing.
