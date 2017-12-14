# Docker image wrapping the Illumina bcl2fastq conversion tool

This container wraps the bcl2fastq service.

## Example usage:

Print the bcl2fastq version (default):
```
docker run --rm umccr/bcl2fastq
```
Print the help:
```
docker run --rm umccr/bcl2fastq --help
```

Convert a dataset
```
docker run --rm -v /tmp/data/input:/tmp/data/input:ro -v /tmp/data/output:/tmp/data/output umccr/bcl2fastq -R /tmp/data/input -o /tmp/data/output --sample-sheet /tmp/data/input/SampleSheet.csv --no-lane-splitting &> /tmp/data/output/bcl2fastq.log
```
