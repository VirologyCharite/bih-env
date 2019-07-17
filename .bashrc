#!/bin/bash

set -Eeuo pipefail

top=/fast/projects/civ-diagnostics/work
bashrc=$top/.bashrc
bin=$top/bin

function civ_setup()
{
    umask 002
    PATH=$bin:$PATH
}

# This is a bit awkwardly done. I don't want to call exit because that will
# cause a user's shell to exit and may completely prevent logging in!

if [ ! -d $top ]
then
    echo "CIV diagnostics top-level directory ($top) does not exist!" >&2
else
    if [ ! -f $bashrc ]
    then
        echo "CIV diagnostics .bashrc ($bashrc) does not exist!" >&2
    else
        if [ ! -d $bin ]
        then
            echo "CIV diagnostics bin directory ($bin) does not exist!" >&2
        else
            civ_setup
        fi
    fi
fi
