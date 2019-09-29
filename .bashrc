top=/fast/projects/civ-diagnostics/work
bashrc=$top/bih-env/.bashrc
bin=$top/bih-env/bin

function civ_setup()
{
    umask 002
    PATH=$bin:$PATH

    local civDate=20190910

    export CIV_PROTEIN_GENOME_DATABASE=$top/databases/civ/$civDate-protein-genome.db
    export CIV_DIAMOND_DATABASE=$top/databases/civ/$civDate-rna-proteins.dmnd
    export CIV_TAXONOMY_DATABASE=$top/databases/civ/$civDate-taxonomy.db
    export CIV_BWA_DATABASE_DIR=$top/databases/bwa

    # This is used by various dark-matter scripts. Set it in case we happen
    # to need to run any of them manually.
    export DARK_MATTER_TAXONOMY_DATABASE=$CIV_TAXONOMY_DATABASE
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
