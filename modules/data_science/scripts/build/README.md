
**A collection of sample notebooks to get you started - More examples will be added as radlab evolves**.


**IMPORTANT NOTE FOR USERS NEW TO JUPYTER NOTEBOOKS:**

* Not all warning messages are bad! Often you will run a cell that will return warnings in the output (sometimes these warnings will even be alarmingly color-coded in red or pink). This does not mean that the cell was not successful, and these warnings can often be ignored.


**What's in sample/bigquery-public-data**.

Example AI notebooks (jupyter notebook) in a GCS location that gets added to your AI notebooks when you install Radlab Datascience module, you can update this script to pull or use your own examples from a GCS location based on what is needed for the end users.
 
The notebooks available in this workspace are listed below. If you are entirely new to Jupyter and are not sure where to start, try the first  notebooks at the top of the list (italics)!

* **Python**
    * Py3 - _BigQuery_tutorial.ipynb_
    * Py3 - Exploring_gnomad_on_BigQuery.ipynb
    * Py3 - Quantum_Simulation_qsimcirq.ipynb

PLEASE NOTE:

* This is pragmatic training material - jupyter notebooks, rather than polished presentation material. 
* Only public data is used in these example notebooks.
* Have questions, comments, feedback? Please reach out to your Google account team
* Don’t forget to come back and check for updates on new examples!

The notebooks here use the gnomad public dataset hosted on:

* BigQuery table [*bigquery-public-data.gnomAD.v2_1_1_exomes__chr1*]

## Appendix

### Radlab documentation and support

This code is shared as is for quickly deploying development environments with respective modules on Google Cloud. We advise customer to review the deployment components and consider any security requirements that needs to be met in their own organisation.

### Google Cloud Public dataset - Query cost

* Some of the Notebook samples are designed to Query public datasets hosted on Google cloud
    * Customer may incur additional cost when executing these sample notebooks
    * Costs are related to querying costs of BigQuery Datasets (e.g querying Gnomad dataset)
    * There might also be Network egress charges when moving or downloading these sample data through jupyter notebooks

---

### Contact information

For all GCP support queries reach out to Google Cloud support.

For Radlab specific queries reach out to your Google account team who provisioned Radlab access.

### License

### Workspace Change Log

