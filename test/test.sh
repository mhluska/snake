#!/bin/bash

USAGE="${0} file"
TEST_FILE='test.html'
BROWSER_NAME='google-chrome'
PROJECT_PATH=$(dirname $(dirname $(readlink -f ${0})))
MODULE_PATH="${PROJECT_PATH}/src"

if [ ${#} -lt 1 ]; then
    echo 'Not enough arguments'
    echo "Usage: ${USAGE}"
    exit 1
fi

if [ ! -e ${1} ]; then
    echo "File ${1} does not exist"
    exit 1
fi

which "${BROWSER_NAME}" >/dev/null

if [ ${?} -ne 0 ]; then
    echo "Browser ${BROWSER_NAME} is not installed"
    exit 1
fi

# Read dependencies from test script
# TODO: Make regex find only quotes for string delimeters
modules=$(perl -n -e '/$\.import (\w+).;?\s*$/ && print "$1 "' ${1})

# Trim the trailing whitespace
modules=${modules%?}

# Remove duplicate modules
unique_modules=$(echo ${modules} | sed 's/ /\n/g' | uniq)

if [ ${#modules} -gt ${#unique_modules} ]; then
    echo "Some duplicate modules were included in the test script"
    exit 1
fi

# Build up script tag HTML, starting with the testing library
scripts="<script src='test.js'></script>"
for module in ${unique_modules}; do
    file="${MODULE_PATH}/${module}.js"
    if [ ! -e ${file} ]; then
        echo "File ${file} does not exist"
        exit 1
    fi
    scripts="${scripts}<script src='${file}'></script>"
done
scripts="${scripts}<script src='${1}'></script>"

# Build a script file to run all the tests
jsCode=
for coffeeFile in `find . -type f -name '*.coffee' | grep -v 'test\.coffee'`; do
    className=$(perl -n -e '/class ([\w.]+)/ && print $1' ${coffeeFile})
    jsCode="${jsCode}new ${className}; "
done
jsCode=${jsCode%?}
scripts="${scripts}<script>${jsCode}</script>"

html="<!DOCTYPE html><html><head></head><body>${scripts}</body></html>"
echo ${html} > ${TEST_FILE}
${BROWSER_NAME} ${TEST_FILE} &
