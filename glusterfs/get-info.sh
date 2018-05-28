#!/bin/bash

NAME="node-"
IDS="151 152 153 154 161 162 163 164 165 166"
DATA_DIR=/opt/gfs_data
RET=""
SEP=""
for ID in $IDS; do
  RET+=$SEP
  RET+="$NAME$ID:$DATA_DIR"
  SEP=" "
done
echo $RET
