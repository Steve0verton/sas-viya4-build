#!/bin/bash
# Searches within files and directory names recursively from a given path and replace text
# Search and replace text withtin BOTH directory names, file names and within content of files
# NOTE: Provide the exact working deployment directory path (not the parent)
# NOTE: 'sed' command needs to be GNU version (MacOS does not provide, use Homebrew to change)
# NOTE: 'rename' command is required for this shell script to run
# NOTE: The find command is executed multiple times below to cover multiple levels of recursion manually which ensures the inline directory and file name renames do not conflict
# TODO: make this more protective and build in defense mechanisms
# TODO: provide verbose output to show the directories and files adjusted

echo "======= FIND & REPLACE TOOL ======="
echo "==== Provide fully qualified base directory to search (absolute path preferred, or relative path from current working deployment directory):"
read dir
echo "==== File Search: Enter file pattern to look for (Ex: *.txt or *)"
read filepattern
echo "==== Existing string? (case sensitive)"
read existing
echo "==== Replacement string? (case sensitive)"
read replacement

echo "==== Replacing all occurences of $existing with $replacement in directory names and file names."
echo "== Max Level 1"
find $dir -maxdepth 1 -name "*$existing*" -execdir rename "s/$existing/$replacement/" {} \+
echo "== Max Level 2"
find $dir -maxdepth 2 -name "*$existing*" -execdir rename "s/$existing/$replacement/" {} \+
echo "== Max Level 3"
find $dir -maxdepth 3 -name "*$existing*" -execdir rename "s/$existing/$replacement/" {} \+

echo "==== Replacing all occurences of $existing with $replacement within files matching $filepattern file pattern."
find $dir -type f -name "$filepattern" -exec sed -i'' -e "s/$existing/$replacement/g" {} +
