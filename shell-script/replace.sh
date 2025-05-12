#!/bin/bash

# Check for minimum arguments
if [ $# -lt 3 ]; then
    echo "Usage: $0 <location> [-r] <find_string> <replace_string>"
    exit 1
fi

location="$1"
if [ ! -e "$location" ]; then
    echo "Error: Location '$location' does not exist."
    exit 1
fi

shift

recursive=0
if [ "$1" = "-r" ]; then
    recursive=1
    shift
fi

if [ $# -ne 2 ]; then
    echo "Usage: $0 <location> [-r] <find_string> <replace_string>"
    exit 1
fi

find_str="$1"
replace_str="$2"

# Configure find command based on recursion
if [ "$recursive" -eq 1 ]; then
    find_cmd=(find "$location" -depth -name "*${find_str}*")
else
    if [ -d "$location" ]; then
        find_cmd=(find "$location" -mindepth 1 -maxdepth 1 -name "*${find_str}*")
    else
        find_cmd=(find "$location" -maxdepth 0 -name "*${find_str}*")
    fi
fi

# Process each item safely with whitespace handling
while IFS= read -r -d '' path; do
    dir=$(dirname "$path")
    old_name=$(basename "$path")
    new_name="${old_name//"$find_str"/"$replace_str"}"
    
    if [ "$old_name" != "$new_name" ]; then
        echo "Renaming: $path -> $dir/$new_name"
        mv -- "$path" "$dir/$new_name"
    fi
done < <("${find_cmd[@]}" -print0)

echo "Operation completed."