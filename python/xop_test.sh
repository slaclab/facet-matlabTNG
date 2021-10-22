#!/bin/sh
mpirun -n 16 python -m mpi4py.futures -m xopt.mpi.run xopt_test.yaml

