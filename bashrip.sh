# TODO:
# * add iso extraction via mounting & copying or 7zip; then just delete the iso (prob a better way to do tho?)
# * somehow get ddrescue to abort after a certain percentage successfully ripped
# * improve the logic at 35-40 as it feels a little messy/unoptimised

read -p "BarID: " barid
read -p "DBase: " dbase
read -p " DBID: " dbid

read -p "Drive# " dnum
read -p "Multi? " multi
read -p "2Side? " sides

dpath="/dev/sr$dnum"
final="$barid [$dbase-$dbid"                            # Begin constructing final name
flagList=(                                              # ddrescue flags per stage
    "-nv"
    "-dvr 3"
    "-Rdvr 3"
)

if [[ "${multi,,}" =~ ^(yes|y)$ ]]; then                # Adds disc number if given
    read -p " Disc# " discnum
    final+=",disc-$discnum"
fi
if [[ "${sides,,}" =~ ^(yes|y)$ ]]; then                # Adds disc side if given
    read -p " Side# " discside
    final+=",side-$discside"
fi

final+="]"                                              # Wraps up final name with a closing bracket
dvdbackup -Mpi $dpath -n $barid -ra                     # Attempts to backup entire disc, aborts on error
exstat=$?                                               # Records exit code

if [[ "$exstat" -ne '0' ]]; then                        # Starts ddrescue if aborted
    for flags in "${flagList[@]}"; do                   # Loops ddrescue 3 times with flaglist
        ddrescue -b 2048 $flags $dpath $barid.iso $barid.log
        exstat=$?
    done
fi

mv $barid "$final"                                      # Append identifiers to output
eject $dpath                                            # Eject disc and terminate program