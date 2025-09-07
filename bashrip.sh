# TODO:
# * add iso extraction via mounting & copying or 7zip; then just delete the iso (prob a better way to do tho?)
# * somehow get ddrescue to abort after a certain percentage successfully ripped
# * improve the ddrescue logic as it feels a little messy/unoptimised

read -p "BarID: " barid
read -p "DBase: " dbase
read -p " DBID: " dbid

read -p "Drive# " dnum
read -p "Multi? " multi
read -p "2Side? " sides

dpath="/dev/sr$dnum"
tmpdir=$(mktemp -d --tmpdir=./)
final="$barid [$dbase-$dbid"    # Begin constructing final name
flagList=(                      # ddrescue flags per stage
    "-nv"
    "-dv"
    "-Rdv"
)

if [[ "${multi,,}" =~ ^(yes|y)$ ]]; then    # Adds disc number if given
    read -p " Disc# " discnum
    final+=",disc-$discnum"
fi
if [[ "${sides,,}" =~ ^(yes|y)$ ]]; then    # Adds disc side if given
    read -p " Side# " discside
    final+=",side-$discside"
fi

final+="]"                                      # Wraps up final name with a closing bracket
dvdbackup -Mpi $dpath -o $tmpdir -n disc -ra    # Attempts to backup entire disc, aborts on error
exstat=$?                                       # Records exit code

if [[ "$exstat" -ne '0' ]]; then                                                  # Checks if dvdbackup aborted
    rm -r "$tmpdir/disc"                                                          # Removes dvdbackup output
    for flags in "${flagList[@]}"; do                                             # Loops ddrescue 3 times, incrementing flaglist
        ddrescue -b 2048 $flags $dpath "$tmpdir/disc.iso" "$tmpdir/rescue.log"    # Runs ddrescue with flags from flaglist array
    done
    mv "$tmpdir/disc.iso" "$final.iso"
else
    mv "$tmpdir/disc" "$final"
fi

eject $dpath    # Eject disc and terminate program