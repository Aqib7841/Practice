#!/bin/bash

files=$(find /tmp -type f -size +1G 2>/dev/null)

if [ -z "$files" ]
then
    echo "No files larger than 1GB were found in /tmp."
    exit $?
fi

echo "  The following large files were found:"

find /tmp -type f -size +1G  2>/dev/null -exec ls -l {} \; | awk '{print "  File name: "$9"\n  Size: "$5" bytes\n"}'

read -p "Do you want to delete these files? (yes/no):" answer

if [ "$answer" == "yes" ]
then
    echo "Deleting the selected files...."
find /tmp -type f -size +1G  2>/dev/null -exec rm {} \;
else
    echo "No files were deleted."
fi

