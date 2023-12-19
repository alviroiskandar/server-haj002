#!/bin/bash

#
# For an unknown reason, a git submodule of elk cannot be built
# using docker-compose up --build. This script will clone
# the elk repository and build the docker image if there is
# no available elk instance on the machine.
#

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P );

if [ ! -f "${parent_path}/elk_git/Dockerfile" ]; then
    git clone https://github.com/elk-zone/elk.git "${parent_path}/elk_git";
fi;
