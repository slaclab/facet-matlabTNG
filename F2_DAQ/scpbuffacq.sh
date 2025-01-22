#!/bin/bash

pvcall -w $1 "FACET-II:BUFFACQ" TIMEOUT=$1 BPMD=57 NRPOS=$2 BPMS=$3
