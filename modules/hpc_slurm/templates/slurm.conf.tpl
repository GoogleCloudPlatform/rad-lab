# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

ControlMachine=${CONTROLLER_HOST_NAME}

AuthType=auth/munge
AuthInfo=cred_expire=120
AuthAltTypes=auth/jwt
CredType=cred/munge
MpiDefault=${MPI_DEFAULT}
LaunchParameters=enable_nss_slurm,use_interactive_step

PrivateData=cloud
ProctrackType=proctrack/cgroup

ReturnToService=2
SlurmctldPidFile=/var/run/slurm/slurmctld.pid
SlurmctldPort=6820-6830
SlurmdPidFile=/var/run/slurm/slurmd.pid
SlurmdPort=6818
SlurmdSpoolDir=/var/spool/slurmd
SlurmUser=slurm
StateSaveLocation=${STATE_SAVE_LOCATION}
SwitchType=switch/none
TaskPlugin=task/affinity,task/cgroup

# TIMERS
CompleteWait=${COMPLETE_WAIT_TIME}
InactiveLimit=0
KillWait=30
MessageTimeout=60
MinJobAge=300
SlurmctldTimeout=120
SlurmdTimeout=300
Waittime=0

# SCHEDULING

SchedulerType=sched/backfill
SelectType=select/cons_tres
SelectTypeParameters=CR_Core_Memory

# JOB PRIORITY

# LOGGING AND ACCOUNTING
AccountingStorageHost=${CONTROLLER_HOST_NAME}
AccountingStorageType=accounting_storage/slurmdbd
AccountingStoreFlags=job_comment
ClusterName=${CLUSTER_NAME}
JobCompType=jobcomp/none
JobAcctGatherFrequency=30
JobAcctGatherType=jobacct_gather/linux
SlurmctldDebug=info
SlurmctldLogFile=${LOG_DIRECTORY}/slurmctld.log
SlurmdDebug=info
SlurmdLogFile=${LOG_DIRECTORY}/slurmd-%n.log

PrologSlurmctld=${SCRIPT_DIRECTORY}/resume.py
EpilogSlurmctld=${SCRIPT_DIRECTORY}/suspend.py

# POWER SAVE SUPPORT FOR IDLE NODES (optional)
#SuspendProgram=${SCRIPT_DIRECTORY}/suspend.py
#ResumeProgram=${SCRIPT_DIRECTORY}/resume.py
#ResumeFailProgram=${SCRIPT_DIRECTORY}/suspend.py
SuspendTimeout=${SUSPEND_TIMEOUT}
ResumeTimeout=${RESUME_TIMEOUT}
ResumeRate=0
SuspendRate=0
SuspendTime=${SUSPEND_TIMEOUT}
SchedulerParameters=salloc_wait_nodes
SlurmctldParameters=cloud_dns,idle_on_node_suspend
CommunicationParameters=NoAddrCache
GresTypes=gpu