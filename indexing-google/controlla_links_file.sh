#!/bin/ksh

while IFS= read -r line
do 
printf "Controllo ---> $line "
python3 ./check_indexed_pages.py $line
done < tutti_links.txt


