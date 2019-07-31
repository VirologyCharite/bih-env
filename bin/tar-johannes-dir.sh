#!/bin/sh

set -Eeuo pipefail

case $# in
    0) echo "Usage: $(basename $0) directory..." >&2; exit 1;;
esac

umask 002

top=$(/bin/pwd)

# outdir=/fast/groups/ag_drosten/work
outdir=.

for dir in "$@"
do
    echo "Processing $dir"

    tarfile=$outdir/$dir.tar.gz
    stdout=$outdir/$dir.tar.stdout
    stderr=$outdir/$dir.tar.stderr
    echo "  Running tar -c -f $tarfile -v -z --exclude '*.fastq.gz' $dir > $stdout 2> $stderr"
    tar -c -f $tarfile -v -z --exclude '*.fastq.gz' $dir > $stdout 2> $stderr
    chmod a-w $tarfile

    # Remove all files whose names do not end in .fastq.gz because these
    # have just been put into the archive.
    echo "  Removing non-fastq"
    find $dir -type f \( \! -name '*.fastq.gz' \) -print0 | xargs -0 -n 500 rm

    # Make all FASTQ files read only.
    # find $dir -type f -print0 | xargs -0 -n 500 chmod a-w

    # Make all sub-directories group read/write.
    # find $dir -type d -print0 | xargs -0 -n 500 chmod 770

    # Repeatedly do a find to locate empty directories and remove them. Do
    # it this way so we can figure out when to stop (we can't do it all at
    # once because we need to go bottom up and repeatedly test dirs that
    # may have become empty leaves on the last iteration due to removal of
    # their empty sub-directories).  The exit status of find doesn't change
    # when it finds no empty dirs, so we can't rely on that to know when to
    # exit. I'm deliberately doing double work here so find can do the
    # removal instead of worrying about dealing with directories with
    # spaces in their names.
    echo "  Removing empty dirs"
    tmp=$(mktemp)
    echo x > $tmp
    while [ -s $tmp ]
    do
        find $dir -type d -empty -delete
        find $dir -type d -empty > $tmp
    done
    rm $tmp

    echo
done
