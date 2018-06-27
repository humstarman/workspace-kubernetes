#!/bin/bash

systemctl stop glusterd.service glusterfsd.service glusterfssharedstorage.service
systemctl disable glusterd.service glusterfsd.service glusterfssharedstorage.service
