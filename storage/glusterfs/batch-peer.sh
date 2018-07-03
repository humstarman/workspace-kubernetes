#!/bin/bash

NAME="node-"
IDS="151 152 153 154 162 163 164 165 166"
for ID in $IDS; do
  gluster peer probe $NAME$ID
done
