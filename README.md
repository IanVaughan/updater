## Updater

Sinatra WebApp for my work colleges (and us devs!) to update remote target/hosts with selected release.

### Notes

Some obfuscation has been made on names/paths for security/etc.

Very specific to our network setup and workflow.

### Overview

Presents user with a choice of 

* Software Releases, or
* User Dev builds
* Target destination Hosts 
* Calibration files to include/use
* Config override (wip)

And a some buttons 

* Update software
* Update cal
* Start software (wip)

### Usage

1. User selects either a known official release, or if desired (or user is a dev) can select a User Dev Head build. (Selecting a Release takes precedence over User)
1. User can optionally put calibration files to be used into the drop folder, `\\server\project\cal\Software\Calibration`
1. Then select which target/host system to update
1. Then hit Go/Update Software
1. Sever then executes an external script (not part of this web app), which performs the required actions of coping the required files to the desired server
1. Once the script has completed, a done page will be shown with the results/output from the script



### Todo
1. Would be nice to include links from `done.erb` to the start/process logs
1. Not thread/multi-user safe! (see next point)
1. Uses files to save state, they either need to be unique (timestamp/GUID) or just save in memory
1. Doesnt dynamical get remote hosts list from master file (external)


