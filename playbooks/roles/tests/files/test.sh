#!/bin/bash
set -e
cd 
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $THIS_DIR/pbs_helpers.sh
source ~/.bash_profile

function make_uuid_str {
    uuid_str=""
    if which uuidgen >/dev/null; then
        uuid_str="$(uuidgen | tr -d '\n-' | tr '[:upper:]' '[:lower:]' | cut -c 1-6)"
    else
        uuid_str="$(cat /proc/sys/kernel/random/uuid | tr -d '\n-' | tr '[:upper:]' '[:lower:]' | cut -c 1-6)"
    fi
}

# Check homedir
echo "Check if /anfhome is mounted"
df | grep anfhome || exit 1
echo "Check if /lustre is mounted"
df | grep lustre || exit 1

# Check PBS
export PBS_MAX_WALLTIME="00:20:00"
echo "Check PBS"
echo "Run qstat"
qstat || exit 1

#
#   Single Node test
#

make_uuid_str
job_group=$uuid_str
echo "Submit single mpicore single node jobs"
submit_job $job_group 1 1 hb60rs ~/job.sh Standard_HB60rs
submit_job $job_group 1 1 hc44rs ~/job.sh Standard_HC44rs
submit_job $job_group 1 1 hb120rs_v2 ~/job.sh Standard_HB120rs_v2
submit_job $job_group 1 1 hb120rs_v3 ~/job.sh Standard_HB120rs_v3

echo "Test GPU node"
submit_job $job_group 1 1 viz3d ~/job_gpu.sh

echo "Submit single node on default"
qsub -l walltime=$PBS_MAX_WALLTIME -N $job_group -k oe -j oe -l select=1 -- ~/job.sh any 

echo "Wait for jobs"
wait_alljobs $job_group

echo "Run pbsnodes"
pbsnodes -avS || exit 1

echo "Get job status"
check_jobstatus $job_group

#
#   Two Nodes test
#

make_uuid_str
job_group=$uuid_str
echo "Submit single mpicore two nodes jobs"
submit_job $job_group 2 1 hb60rs ~/job.sh Standard_HB60rs
submit_job $job_group 2 1 hc44rs ~/job.sh Standard_HC44rs
submit_job $job_group 2 1 hb120rs_v2 ~/job.sh Standard_HB120rs_v2
submit_job $job_group 2 1 hb120rs_v3 ~/job.sh Standard_HB120rs_v3

echo "Submit two nodes on default"
qsub -l walltime=$PBS_MAX_WALLTIME -N $job_group -k oe -j oe -l select=2 -- ~/job.sh any 

echo "Wait for jobs"
wait_alljobs $job_group

echo "Run pbsnodes"
pbsnodes -avS || exit 1

echo "Get job status"
check_jobstatus $job_group
