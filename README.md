# IBM Data Accelerator for AI and Analytics Samples

This repository provides sample code to enable a Data Accelerator for AI and Analytics solution as described in the IBM RedPaper:
[Data Accelerator for AI and Analytics] (http://www.redbooks.ibm.com/redpieces/abstracts/redp5623.html)
The scripts only provide a sample for a proof of concept environment described in the paper.

It connects the following products: IBM Spectrum Scale, IBM Spectrum LSF, IBM Spectrum Discover, IBM Spectrum Archive, Red Hat OpenShift to provide a data orchestrated environment to address typical challenges that arise when dealing with large and ever-growing amounts of data for data analytics. It is able to handle single NFS, OBJ and Scale cluster IBM Spectrum Scale Active File Management (AFM) relationships.
The scripts must not be used in a production environment. As they only provide a sample on how the API's between the different products could be connected, any error handling is missing.

The scripts provide sample code to trigger a workload via a template used in IBM Spectrum LSF and how a workflow could be started by using the automated metadata catalog update in Spectrum Discover.

Further scripts provide an example about running a workload in Pod's scheduled in an OpenShift environment.


## Support

The provided sample code is not part of an IBM offering. Please contact code contributors for questions. Answers are provided as team availability permits.

## Report Bugs 

For help with issues, suggestions, recommendations, feature requests, feel free to open an issue in [github](https://github.com//IBM/ibm-spectrum-scale-daaa/issues).
Issues will be addressed as team availability permits.

## Contributing

We welcome contributions to this project, see [Contributing](CONTRIBUTING.md) for more details.


## Workflow to Script Details

The following provides more details about the sample scripts, the needed arguments and what output is generated
Code can be divided into the following parts:

### Core code running generic workflow

Scripts to run the generic workflow can be found in the [core](core/README.md) directory.
Some details are logged for later review. Logfiles can be found in the user home directory in our case `/home/dean/` on the IBM Spectrum Spectrum LSF node.


### Workload triggers

Scripts that trigger the workflow can be found in the [trigger](trigger/README.md) directory.


### Workload execution
Scripts that execute the workload in example OpenShift, including managing the persistent volumes can be found in the [workloads](workloads/README.md) directory.
