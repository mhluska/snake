# TODO: Make only constants capital case. Others camel case.

#!/bin/bash

TEST_FILE='test.html'
BROWSER_NAME='Google Chrome'

if [ $(uname -s) == 'Darwin' ]; then
    
    READLINK_PATH=$(which greadlink)
    if [ ${?} -ne 0 ]; then
        echo 'greadlink is not installed. Try brew install coreutils.'
        exit 1
    fi

    BROWSER_PATH='/Applications/Google Chrome.app'
    if [ ! -e "${BROWSER_PATH}" ]; then
        echo "Browser ${BROWSER_NAME} is not installed"
        exit 1
    fi
    BROWSER_OPEN_COMMAND='/usr/bin/open -a'

else

    READLINK_PATH=$(which readlink)

    BROWSER_PATH=$(which google-chrome)
    if [ ${?} -ne 0 ]; then
        echo "Browser ${BROWSER_NAME} is not installed"
        exit 1
    fi

    BRWOSER_OPEN_COMMAND=
fi

PROJECT_PATH=$(dirname $(dirname $(${READLINK_PATH} -f ${0})))
MODULE_PATH="${PROJECT_PATH}/src"

remove_duplicates() {

    echo $(echo ${1} | sed 's/ /\'$'\n/g' | awk ' !x[$0]++')
}

parse_dependencies() {

    # Read dependencies from a testing CoffeeScript file
    # TODO: Make regex find only quotes for string delimeters
    MODULES=$(perl -n -e '/$\.import (\S+).;?\s*$/ && print "$1 "' ${1})

    # Trim the trailing whitespace
    MODULES=${MODULES%?}

    UNIQUE_MODULES=$(remove_duplicates "${MODULES}")

    if [ ${#MODULES} -gt ${#UNIQUE_MODULES} ]; then
        echo 'Some duplicate modules were included in the test script'
        exit 1
    fi

    echo ${UNIQUE_MODULES}
}

build_dependency_html() {

    HTML=
    for module in ${1}; do

        if [ -n "$(echo "${module}" | grep 'https\?://.*')" ]; then
            FILE="${module}"
        else

            FILE=$(find "${MODULE_PATH}" -type f -name "${module}.js")
            if [ -z ${FILE} ]; then
                echo "Module ${module} does not exist"
                exit 1
            fi
        fi

        HTML="${HTML}<script src='${FILE}'></script>"
    done

    echo ${HTML}
}

# Build up some HTML and JavaScript to run all the tests
SCRIPTS=
JS_CODE=
DEPENDENCIES=
for COFFEE_FILE in `find . -mindepth 2 -type f -name '*.coffee' | grep -v 'test\.coffee'`; do

    CLASS_NAME=$(perl -n -e '/class ([\w.]+)/ && print $1' ${COFFEE_FILE})
    JS_CODE="${JS_CODE}new ${CLASS_NAME}; "

    COFFEE_PATH=$(dirname $(${READLINK_PATH} -f "${COFFEE_FILE}"))
    JS_PATH="${COFFEE_PATH}/$(basename "${COFFEE_FILE}" '.coffee').js"
    if [ ! -e "${JS_PATH}" ]; then
        echo "File ${JS_PATH} does not exist. Try compiling ${COFFEE_FILE}."
        exit 1
    fi
    SCRIPTS="${SCRIPTS}<script src='${JS_PATH}'></script>"
    DEPENDENCIES="${DEPENDENCIES} $(parse_dependencies ${COFFEE_FILE})"
done

JS_CODE=${JS_CODE%?}
DEPENDENCIES=$(remove_duplicates "${DEPENDENCIES}")

touch config.js

read -d '' HTML << EOF
<!DOCTYPE html>
    <head>
        <link href='http://fonts.googleapis.com/css?family=Open+Sans:400,600,700' rel='stylesheet' type='text/css'>
        <link rel="stylesheet" type="text/css" href="test.css" />
        <script src='../lib/mustache.js'></script>
        <script src='config.js'></script>
        <script src='test.js'></script>
        $(build_dependency_html "${DEPENDENCIES}")
        ${SCRIPTS}
    </head>
    <body>
        $(cat templates.html)
        <script>${JS_CODE}</script>
    </body>
</html>
EOF

echo ${HTML} > ${TEST_FILE}

${BROWSER_OPEN_COMMAND} "${BROWSER_PATH}" "${TEST_FILE}" &
