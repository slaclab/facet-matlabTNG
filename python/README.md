# Matlab interface to the Xopt module

* Requires Matlab and Matlab parallel computing toolbox (see Matlab documentation for your release to check for compative Python version).
* Uses Matlab Python Engine to call user-provided Matlab function for objective function calls.
* Uses mpirun to execute Xopt code

## Contents

* xopt_example.mlx - Matlab live script. Example of running Xopt optimizer from within Matlab environment, and comparison with builtin Matlab optimizer.
* Xopt.m - Matlab class file to interface with Xopt (needs to be in Matlab search path)
* xopt_fun.m - Used by Xopt.m (needs to be in Matlab search path)
* TNK_constraints.m - Definition of constraints for TNK example used by Matlab optimizer gamultiobj
* TNK_opt.m - TNK example function and constraints used by Xopt

## Run TNK optimization example from within Matlab

* internally generates xopt_eval.py & xopt_eval.yaml files in local directory at run time for running Xopt
```MATLAB
help Xopt % instructions for using Xopt class
xopt_example % Runs example using fitnessfcn_xopt.m as example objective function (further documentation and results seen within live script)
```
