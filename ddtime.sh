#!/bin/bash
dir="`pwd`"
dbname="ddnet.sqlite"
db="$dir/$dbname"
ddtime="ddtime.sh"

if [ ! -f "$db" ]; then
    echo "$dbname not found!";
    echo "Make sure that you have downloaded the database and put it in the same folder as $ddtime ($dir)";
    exit;
fi 

map="$1";

name="$2";
if [[ -z $2 ]]; then
	name="marzzzello"; #Change marzzzello here to your preferred default nickname
fi

t="$3"; 
if [[ -z $3 ]]; then
	t="10"; 		#The default is to look the 10 minutes before and after your finish
fi

if [[ -z $1 ]]; then
	echo "Usage: ./$ddtime map [name (default: $name)] [difftime in minutes (default: $t)]";
	exit;
fi

IFS=$'\n'
for OUTPUT in $(echo "select timestamp from race where name='$name' and map='$map'
order by Timestamp asc;" | sqlite3 "$db" --noheader)
do
    
    echo $OUTPUT
    echo "select Name, 
    round((strftime('%s', Timestamp) - strftime('%s', '$OUTPUT')) / 60.0,1) as 'Difference in minutes',
    round(Time/60) as 'Finish time in minutes' 
    from race where Map='$map' 
    AND Timestamp >= datetime('$OUTPUT', '-$t minutes')
    AND Timestamp <= datetime('$OUTPUT', '+$t minutes')
    order by Timestamp asc;" | sqlite3 "$db" --column --header
 
done
