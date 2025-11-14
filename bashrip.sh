# TODO:
#   add iso extraction via mounting & copying or 7zip; then just delete the iso (prob a better way to do tho?)
#   somehow get ddrescue to abort after a certain percentage successfully ripped
#   improve the ddrescue logic as it feels a little messy/unoptimised

# posix var
OPTIND=1    # flush in case getopts was used in shell previously

# program vars
loop=false
input=""
output=""

# argument parser
while getopts "li:o:" opt; do
    case "$opt" in
        l) loop=true ;;
        i) input=$OPTARG ;;
        o) output=$OPTARG ;;
    esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift

# process initialization
tmpdir=$(mktemp -d --tmpdir=./)
flagList=(                         # ddrescue flags per stage
    "-nv"
    "-dv"
    "-Rdv"
)

# process start
dvdbackup -Mpi $input -o $tmpdir -n disc -ra    # Attempts to backup entire disc, aborts on error
exstat=$?                                       # Records exit code

if [[ "$exstat" -ne '0' ]]; then                         # Starts ddrescue if aborted
    rm -r $tmpdir/disc
    for flags in "${flagList[@]}"; do                      # Loops ddrescue 3 times with flaglist
        ddrescue -b 2048 $flags $in $out.iso $out.log
    done
    mv $tmpdir/disc.iso "$output.iso"
    rm $tmpdir/rescue.log*
else
    mv $tmpdir/disc "$output"
fi

# finalize process
rmdir $tmpdir    # Remove temporary directory
eject $dpath     # Eject disc and terminate program