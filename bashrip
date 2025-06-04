read -p "BarID: " barid
read -p "DBase: " dbase
read -p " DBID: " dbid

read -p "Drive# " drive
read -p "Multi? " multi
read -p "2Side? " sides

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
dvdbackup -Mpi /dev/sr$drive -n $barid -ra
exstat=$?

if [ $exstat -ne 0 ]; then
    rm -r $barid
    safecopy --stage1 /dev/sr0 "$final.iso"
    safecopy --stage2 /dev/sr0 "$final.iso"
    safecopy --stage3 /dev/sr0 "$final.iso"
    rm stage*.badblocks
else
    mv $barid "$final"
fi

eject /dev/sr$drive
