#!/bin/bash

# write the script logs next to the script itself
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
function write_log {
  echo "$(date +'%Y%m%d%H%M'): $1" >> $DIR/$(basename $0).log
}

write_log "Script parameters: $*"

if [[ $# -lt 4 ]]; then
  echo "A minimum of 4 arguments are required!"
  echo "  1) The runfolder directory [-R|--runfolder-dir]"
  echo "  2) The runfolder name [-n|--runfolder-name]"
  echo "  3) The output directory [-o|--output-dir]"
  echo "  4) An st2 api key [-k|--st2-api-key]"
  exit -1
fi

bcl2fastq_version="latest"
optional_args=()
while [[ $# -gt 0 ]]
do
  key="$1"

  case $key in
    -v|--bcl2fastq-version)
      bcl2fastq_version="$2"
      shift # past argument
      shift # past value
      ;;
    -o|--output-dir)
      output_dir="$2"
      shift # past argument
      shift # past value
      ;;
    -R|--runfolder-dir)
      runfolder_dir="$2"
      shift # past argument
      shift # past value
      ;;
    -n|--runfolder-name)
      runfolder_name="$2"
      shift # past argument
      shift # past value
      ;;
    -k|--st2-api-key)
      st2_api_key="$2"
      shift # past argument
      shift # past value
      ;;
    *)    # unknown option (everything else)
      optional_args+=("$1") # save it in an array for later
      shift # past argument
      ;;
  esac
done

if [[ -z "$output_dir" ]]; then
  echo "You have to define an output directory!"
  exit -1
fi

if [[ -z "$runfolder_dir" ]]; then
  echo "You have to define a runfolder directory!"
  exit -1
fi

if [[ -z "$runfolder_name" ]]; then
  echo "You have to define a runfolder name!"
  exit -1
fi

if [[ -z "$st2_api_key" ]]; then
  echo "You have to provide an st2 api key!"
  exit -1
fi


# make sure the output directory exists
mkdir_command="mkdir -p \"$output_dir\""
write_log "creating output dir: $mkdir_command"
eval $mkdir_command

# run the actual conversion
cmd="docker run --rm -d -v $runfolder_dir:$runfolder_dir:ro -v $output_dir:$output_dir umccr/bcl2fastq:$bcl2fastq_version -R $runfolder_dir -o $output_dir ${optional_args[*]} >& $output_dir/${runfolder_name}.log"
#cmd="docker run --rm -d -v $runfolder_dir:$runfolder_dir:ro -v $output_dir:$output_dir umccr/bcl2fastq:$bcl2fastq_version -R $runfolder_dir -o $output_dir ${optional_args[*]}"
write_log "running command: $cmd"
write_log "writing logs to: $output_dir/${runfolder_name}.log"
eval $cmd
ret_code=$?

status="done"
if [ $ret_code != 0 ]; then
  status="error"
fi
write_log "bcl2fastq exit status: $status (code: $ret_code)"

# finally notify StackStorm of completion
webhook="curl --insecure -X POST https://arteria.umccr.nopcode.org/api/v1/webhooks/st2 -H \"St2-Api-Key: $st2_api_key\" -H \"Content-Type: application/json\" --data '{\"trigger\": \"umccr.bcl2fastq\", \"payload\": {\"status\": \"$status\", \"runfolder_name\": \"$runfolder_name\", \"runfolder\": \"$runfolder_dir\"}}'"
write_log "calling home: $webhook"
eval $webhook
