#!/bin/ksh

### QUESTO SCRIPT FUNZIONA SU KSH e GNU-SED in ambiente OPENBSD 7.1
### https://leucalipto.blogspot.com
### devi scaricare la sitemap.xml per esempio in questo modo:
### wget https://leucalipto.blogspot.com/sitemap.xml


## Colors:
NORM="\033[0m"
BLACK="\033[0;30m"
GRAY="\033[1;30m"
RED="\033[0;31m"
LRED="\033[1;31m"
GREEN="\033[0;32m"
LGREEN="\033[1;32m"
YELLOW="\033[0;33m"
LYELLOW="\033[1;33m"
BLUE="\033[0;34m"
LBLUE="\033[1;34m"
PURPLE="\033[0;35m"
PINK="\033[1;35m"
CYAN="\033[0;36m"
LCYAN="\033[1;36m"
LGRAY="\033[0;37m"
WHITE="\033[1;37m"

aiuto() {
    echo ""
    echo "------------------------------------------"
    echo "Prima di procedere scaricare il sitemap.xml"
    echo "Ex: $ wget https://leucalipto.blogspot.com/sitemap.xml"
    echo ""
    echo $BLUE"Semplice script basato su sed per"
    echo "convertire un file sitemap.xml in csv $NORM"
    echo "$0 nome_file_sitemap.xml"
    echo "Ex: $YELLOW $0 $RED sitemap.xml $BLUE >> $WHITE data.csv $NORM"
    echo "-------------------------------------------"
    echo ""
}

[[ $# < 1 ]] && aiuto && echo $RED"\nErr:$NORM lo script deve avere almeno un parametro \n\n" && exit
[[ $# > 1 ]] && aiuto && echo $RED"Err:$NORM lo script puÃ avere non piÃ¹ di un parametro \n\n" && exit

( which gsed 2>&1 > /dev/null 2>/dev/null && echo "GNU-sed trovato, procedo" ) || ( echo "GNU-sed non trovato, questo script funziona con la versione gnu di sed e non con lo standard sed di OpenBSD" && exit )
echo "URL,date"
cat $1 | gsed 's/<url><loc>/\n/g;s/<\/loc><lastmod>/,/g;s/<\/lastmod><\/url>//g;s/<\/urlset>//g' | sed '/sitemaps/d'
echo ""

