

#!/bin/bash

# This script takes a list of user names from stdin,
# runs search API queries that produce counts data,
# and saves the results.

start_time="2015-09-10T00:00:00.000Z"
end_time="2015-10-10T00:00:00.000Z"
search_cmd=/Users/snelson/projects/tools/Gnip-Python-Search-API-Utilities/gnip_search.py
output_dir=data/counts
mkdir -p $output_dir

counter=0
user_count=0
query="from:"
while read user; do
    #echo "Doing ${counter}: $user" 1>&2
    let "user_count+=1"
    # collect 100 users
    if [[ $user_count -lt 100 ]]; then
        query=$query$user" OR from:"
        continue
    else
    	query=$query$user
    	echo "$query"
    	output_file_name="search_data_user-${counter}.json"
		${search_cmd} -a -t -f "$query" -s $start_time -e $end_time -b day timeline > ${output_dir}/${output_file_name} 2> /dev/null
    	echo Sleeping...
    	sleep 0.1
    	#reset user_count
    	user_count=0
    	query="from:"
    fi

    let "counter+=1"
done 

## sum the counts and print it out
find ./data -type f | xargs -I {} cat {} | jq .results[] | jq --raw-output '"\(.timePeriod)\t\(.count)"' | sort | awk '{a[$1]+=$2}END{for(i in a) print i,a[i]}' | sort
echo "DONE"