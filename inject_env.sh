#!/bin/bash
#inject_env.sh: A simple tool to substitute bash env ($var) in all files with .yml/.yaml extension from a given file
# Usage (--env-file|-e)=<path-to-env> and (--root-path|-p)-<path-to-root-dir>
set -e



#Parse --arg=val
for arg in "$@"; #basically, "for each arg in args"
do
  case $arg in
    #<pattern>
    --env-file=*|-e=*) ENVFILE="${arg#*=}";; # ")" just closes the bash pattern
    --root-path=*|-p=*) ROOTPATH="${arg#*=}";; #this all means "match all after first ="
  esac
done



echo "Substituting ENVS in $ROOTPATH subfiles from env_file $ENVFILE"
#Finds all paths to .yml|yaml
FILES=$(find $ROOTPATH -regex '.*\.\(yml\|yaml\)$')

#Read all envs
mapfile -t ENV_VARS < <(grep -Ev '^#|^[[:space:]]*$' $ENVFILE)
VARS=$(printf '$%s ' "${ENV_VARS[@]%%=*}")
echo "Variables: $VARS"
for file in $FILES
do
    #grep here gives us all content of file BUT #comments
    #thus we get VARIABLE=VALUE pairs
    #env command creates an isolated env with these vars
    #envsubst substitutes vars from $file with these vars and saves to .temp file
    #then we overwrite the original with temp.

    echo $file
    env "${ENV_VARS[@]}" envsubst "${VARS}" < $file > "${file}.temp"
    mv "${file}.temp" $file
done