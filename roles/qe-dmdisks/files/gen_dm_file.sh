#!/bin/bash

if [ $# -lt 6 -o "$1" == "-help" -o "$1" == "-h" ]; then
  echo "This script generates file with map for device mapper."
  echo "Usage: $0 <full path to device> <table format> <first failure> <repeat failure> <failed set> <set number> [<flakey args>]"
  echo "<full path to device>: for example '/dev/vdb'"
  echo "<table format>: can be one of: 'flakey', 'zero', 'delay', 'error'"
  echo "<first failure>: first failure is after X MB from disk "
  echo ""
fi

device=$1
table_format=$2
first_failure_at=$3
repeat_failure_every=$4
failed_block_size=$5
number_of_failed_blocks=$6
flakey_args=${@:7}

# Get disk size and size of one sector
lsblk_out=$(lsblk -b --output 'SIZE,PHY-SEC' ${device} | tail -1)

disk_size=$(echo ${lsblk_out} | tr -s ' ' | cut -d ' ' -f 1)
sector_size=$(echo ${lsblk_out} | tr -s ' ' | cut -d ' ' -f 2)

# Get number of sectors
block_count=$(echo ${lsblk_out} | tr -s ' ' '/' | bc)

# Get number of sectors till first faulty set of sectors
block100=$(echo "${first_failure_at}*1024*1024/${sector_size}" | bc)

# Get number of failed sectors in one sector set
failed_set=$(echo "${failed_block_size}*1024/${sector_size}" | bc)

# Get number of failed sectors till next failure
repeated_set=$(echo "${repeat_failure_every}*1024*1024/${sector_size}" | bc)

#block100=10
#failed_set=5
#repeated_set=10
#block_count=500

# 0 10 linear /dev/vdb 0
# 10 5 flakey /dev/vdb 10 1 1
# 15 10 linear /dev/vdb 15
# 25 5 flakey /dev/vdb 25 1 1
# 30 10 linear /dev/vdb 30


# 0 10 linear /dev/vdb 0
# 10 5 error
# 15 10 linear /dev/vdb 10
# 25 5 error
# 30 10 linear /dev/vdb 20

echo "0 ${block100} linear ${device} 0"
head=${block100}

if [ "${table_format}" == "flakey" ]; then
  for i in `seq ${number_of_failed_blocks}`; do
    echo "${head} ${failed_set} flakey ${device} ${head} ${flakey_args}"
    head=$((${head} + ${failed_set}))
    echo "${head} ${repeated_set} linear ${device} ${head}"
    head=$((${head} + ${repeated_set}))
  done

  echo "${head} $((${block_count} - ${head})) linear ${device} ${head}"
else
  head2=${block100}
  for i in `seq ${number_of_failed_blocks}`; do
    echo "${head} ${failed_set} ${table_format}"
    head=$((${head} + ${failed_set}))
    echo "${head} ${repeated_set} linear ${device} ${head2}"
    head=$((${head} + ${repeated_set}))
    head2=$((${head2} + ${repeated_set}))
  done
  echo "${head} $((${block_count} - ${head2})) linear ${device} ${head2}"
fi
