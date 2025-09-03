read -p "BarID: " barid
read -p "DBase: " dbase
read -p " DBID: " dbid

read -p "Drive# " drive
read -p "Multi? " multi
read -p "2Side? " sides

dpath="/dev/sr$drive"
final="$barid [$dbase-$dbid"

if [[ "${multi,,}" =~ ^(yes|y)$ ]]; then
    read -p " Disc# " discnum
    final+=",disc-$discnum"
fi
if [[ "${sides,,}" =~ ^(yes|y)$ ]]; then
    read -p " Side# " discside
    final+=",side-$discside"
fi

final+="]"
dvdbackup -Mpi $dpath -n $barid -ra
exstat=$?

if [ $exstat -ne 0 ]; then
    stage=1
    
    while [$scstat -ne 0 -a $stage <= 3] :; do
        rm -r $barid
        safecopy --stage$stage $dpath "$barid"
        scstat=$?
        let "stage++"
    done

    final+=".iso"
    rm "stage*.badblocks"
fi

mv "$barid" "$final"
eject $dpath
