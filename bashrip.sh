: '
TODO:
    add iso extraction via mounting & copying or 7zip; then delete the iso (prob a better way to do tho?)
    have ddrescue abort after a certain (configurable) percentage successfully ripped
    improve ddrescue logic
    add help argument
    check source for duplicate files (prob using rdfind), then ignore those
'

# posix var
OPTIND=1    # flush in case getopts was used in shell previously

# program vars
input=""
output=""
loop=false

# argument parser
while getopts "i:o:l" opt; do
    case "$opt" in
        i) input=$OPTARG ;;
        o) output=$OPTARG ;;
        l) loop=true ;;
    esac
done

shift $((OPTIND-1))
[ "${1:-}" = "--" ] && shift

# invalid argument check
if [ "$loop" = true ]; then
    if [[ "$output" != "" ]]; then
        echo "Please do not use '-l' with '-o', output path will be prompted when necessary"
        exit 1
    elif [[ "$input" == "" ]]; then
        echo "No input path given, use '-i' to specify one"
        exit 1
    fi
fi

# ddrescue flags per stage
flagList=(
    "-nv"
    "-dv"
    "-Rdv"
)

# main loop
while :; do
    # process prep
    tmpdir=$(mktemp -d --tmpdir=./)

    if [ "$loop" = true ]; then
        echo "Process looping, using input $input"
        read -p "Output (barcode): " output
    fi

    # process start
    dvdbackup -Mpi $input -o $tmpdir -n disc -ra    # attempts to backup entire disc, aborts on error
    exstat=$?                                       # records exit code

    if [ "$exstat" -ne '0' ]; then                  # starts ddrescue if aborted
        rm -r $tmpdir/disc

        for flags in "${flagList[@]}"; do                       # loops ddrescue 3 times with flaglist
            ddrescue -b 2048 $flags $in $out.iso $out.log
        done

        mv $tmpdir/disc.iso "$output.iso"
        rm $tmpdir/rescue.log*
    else
        mv $tmpdir/disc "$output"
    fi

    # process end
    rmdir $tmpdir    # remove temporary directory
    eject $dpath     # eject disc and terminate program

    if [ "$loop" = false ]; then    # stop looping if '-l' isn't applied
        break
    fi
done