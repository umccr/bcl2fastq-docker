#!/bin/bash

# TODO
#   - add option to specify a custom SampleSheet
#   - add mechanism to provide additional conversion parameters
#   - add mechanims to select the bcl2fastq (image) version to use

# guard against wrong usage
if [[ $# -ne 3 ]]; then
  echo "3 arguments are required!"
  echo "  1) runfolder directory"
  echo "  2) output directory"
  echo "  3) st2 api key"
  exit -1
fi

runfolder=$1
output_dir=$2
st2_api_key=$3

log_dir="$output_dir"
runfolder_name=`basename $runfolder`
log_file="${runfolder_name}.log"


# run the actual conversion
docker run --rm -v $runfolder:$runfolder:ro -v $output_dir:$output_dir umccr/bcl2fastq -R $runfolder -o $output_dir/$runfolder_name --no-lane-splitting &> $output_dir/$log_file
ret_code=$?

status="done"
if [ $ret_code != 0 ]; then
  status="error"
fi
echo $status

# finally notify StackStorm of completion
webhook="curl --insecure -X POST https://arteria.umccr.nopcode.org/api/v1/webhooks/st2 -H \"St2-Api-Key: $st2_api_key\" -H \"Content-Type: application/json\" --data '{\"trigger\": \"umccr.bcl2fastq\", \"payload\": {\"status\": \"$status\", \"runfolder\": \"$runfolder_name\"}}'"
#echo $webhook
eval $webhook
