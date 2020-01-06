civdir=/fast/work/projects/civ-diagnostics
civlocal=$civdir/root/usr/local
bashrc=$civlocal/bih-env/.bashrc
bin=$civlocal/bih-env/bin
pipelineBin=$civlocal/bih-pipeline/bin

function ssh-restore ()
{
    if [ -z "$TMUX" ]
    then
        echo 'Not in a tmux session!' >&2
    else
        eval $(tmux show-environment | egrep '^SSH_' | sed -e 's/=/="/' -e 's/$/"/')
    fi
}

function civ_setup()
{
    umask 002

    export HOMEBREW_PREFIX=$HOME/.linuxbrew
    export HOMEBREW_CELLAR=$HOME/.linuxbrew/Cellar
    export HOMEBREW_REPOSITORY=$HOME/.linuxbrew/Homebrew
    export MANPATH=$HOME/.linuxbrew/share/man:$MANPATH
    export INFOPATH=$HOME/.linuxbrew/share/info:$INFOPATH
    export PYTHONPATH=$civlocal/bih-pipeline
    # export LIBRARY_PATH=$civdir/packages/linuxbrew/lib
    # export LD_LIBRARY_PATH=$civdir/packages/linuxbrew/lib

    PATH=$bin:$pipelineBin:$HOME/.linuxbrew/bin:$HOME/.linuxbrew/sbin:$PATH

    activate=$civlocal/bih-pipeline-env/bin/activate

    local civDate=20190910
    export CIV_PROTEIN_GENOME_DATABASE=$civdir/databases/civ/$civDate-protein-genome.db
    export CIV_DIAMOND_DATABASE=$civdir/databases/civ/$civDate-rna-proteins.dmnd
    export CIV_TAXONOMY_DATABASE=$civdir/databases/civ/$civDate-taxonomy.db
    export CIV_BWA_DATABASE_DIR=$civdir/databases/bwa
    export CIV_ENVIRONMENT_ACTIVATION_SCRIPT=$activate

    # This is used by various dark-matter scripts. Set it in case we happen
    # to need to run any of them manually.
    export DARK_MATTER_TAXONOMY_DATABASE=$CIV_TAXONOMY_DATABASE

    if [ -f $activate ]
    then
        if [ -z "$VIRTUAL_ENV" ]
        then
           . $activate
        fi
    else
        echo "BIH pipeline virtualenv activate script ($activate) does not exist!" >&2
    fi
}

# This is a bit awkwardly done. I don't want to call exit because that will
# cause a user's shell to exit and may completely prevent logging in!

if [ -f $bashrc ]
then
    if [ -d $bin ]
    then
        civ_setup
    else
        echo "CIV diagnostics bin directory ($bin) does not exist!" >&2
    fi
else
    echo "CIV diagnostics .bashrc ($bashrc) does not exist!" >&2
fi
