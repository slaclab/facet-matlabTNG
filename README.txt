Root directory is facet-sw/ (from https://github.com/slaclab/facet-sw repository)
* Requires Matlab2020a+
* Requires EPICS environment set on run host with access to PVs
* For running in Matlab, the "common" directory in addition to required app directories should be added to the search path.

>>> How to run a facet application:
----------

* Run from facet-sw/matlab

* Use >> runapp('appname') from within Matlab session where appname is one of existing apps (same as directory names)

* Use $ run_F2app.sh <appname> from command line to run compiled app from facet-srv01 host

=============

>>> How to build a new application:
----------

1) Create application directory with same name as application

2) Design app with Matlab App Designer and save mlapp file in application directory

3) Either embed PV info into master app file (see a below) OR make an additional helper function (see b)

a) See Example1.mlapp in ExampleApps
After saving app, select "Code View" tab. You need to add a public property to store the PV info and 2 new private methods
to initialize and configure the PV info and to cleanup after app deletion:
* Create a public propert "pvlist" by using the Property pulldown menu in the editor window
* Create a startup method: click the "App Input Arguments" button in the editor window and provide a dummy input argument.
This will create a new private method "startupFcn" in the Code View window that you can edit. This gets called on startup, you
should add PV initialization commands here- see the corresponding moethod in Example1.mlapp as an example, and the PV class file
and/or documentation for more advanced functionality.
* Create a cleanup method: Click the Callback button in the Editor window, select the "UIFigure" component from the top menu and
the "CloseRequestFcn" from the callback menu. This will generate the private method "UIFigureCloseRequest" and make this available
for editing in the Code View window. You should add the 2 cleanup lines in addition to the app deletion line as shown in the corresponding
method in Example1.mlapp.

b) See Example2.mlapp and corresponding Example2_runme.m function
See >>help Example2_runme.m and the code itself to see how to initialize the PVs and attach to the app using this workflow.
There is no requirement to directly edit the app in Code View in this case.

Note: the intended useage is to launch a fresh Matlab session, launch the app and then exit the Matlab session after the
app is deleted. For testing and other use cases, you should take care to execute the startup & cleanup actions only at the
start and end of the Matlab session to avoid unexpected behavior.