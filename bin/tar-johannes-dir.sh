#!/bin/sh

set -Eeuo pipefail

case $# in
    0) echo "Usage: $(basename $0) directory..." >&2; exit 1;;
esac

umask 002

raw=/fast/work/projects/civ-diagnostics/raw

if [ $(/bin/pwd) != $raw ]
then
    echo "You must run this command in '$raw'." >&2
    exit 1
fi

log=tar-johannes-dir-LOG
echo >> $log
echo "Run at $(date) by user $USER with command line arg(s):" >> $log
for dir in "$@"
do
    echo "    $dir"
done >> $log

# outdir=/fast/groups/ag_drosten/work
outdir=.

for dir in "$@"
do
    echo "Processing $dir"

    # Check that some FASTQ files are actually present under $dir, else the
    # loop at bottom to remove empty directories (once the non-FASTQ files
    # are tarred and then deleted from their original locations) will
    # remove the whole of $dir.
    fastqCount=$(find $dir -type f -name '*.fastq.gz' | wc -l)
    if [ "$fastqCount" -eq 0 ]
    then
        echo "No .fastq.gz files found under directory '$dir'. Skipping." >&2
        continue
    fi

    tarfile=$outdir/$dir.tar.gz
    stdout=$outdir/$dir.tar.stdout
    stderr=$outdir/$dir.tar.stderr

    # Set all files and directories under $dir to be group accessible.
    # Otherwise the umask on the machine they were scp'd from may restrict
    # others on this (BIH) machine.
    find $dir -type f -print0 | xargs -0 -n 500 chmod g+rw
    find $dir -type d -print0 | xargs -0 -n 500 chmod g+rwx

    echo "  Running tar -c -f $tarfile -v -z --exclude '*.fastq.gz' $dir > $stdout 2> $stderr"
    tar -c -f $tarfile -v -z --exclude '*.fastq.gz' $dir > $stdout 2> $stderr
    chmod a-w $tarfile

    # Remove the stderr file if it is empty. At this point it's almost
    # certain to be empty because tar will write to stderr and exit
    # non-zero if there was an error, so we will have already exited in
    # that case. So this is really just a cleanup, with a check in case
    # stderr was written to but tar nevertheless exited with status zero.
    test -s $stderr || rm $stderr

    # Remove all files whose names do not end in .fastq.gz because these
    # have just been put into the archive.
    echo "  Removing non-fastq"
    find $dir -type f \( \! -name '*.fastq.gz' \) -print0 | xargs -0 -n 500 rm

    # This chmod (and the following one) fails for me (Terry) on the BIH
    # cluster when trying to set perms on files owned by Johannes, even
    # when the group I am in has write access to the file in question and
    # its directory. Don't know why. So these two chmod commands commented
    # out for now.
    #
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
