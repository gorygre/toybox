#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

fatal_error()
{
  echo -e "${RED}${1}${NC}"
  echo "${USAGE}"
  exit 1
}

USAGE="
ctest-slice.sh [-r|--repo <PATH>] [-a|--all] [-p|--parallel] -t|--test <TARGET> ...

Tailored manual execution of cmake tests.

examples
  ctest-slice.sh --repo ~/codebase --test Some.UnitTest
  ctest-slice.sh --repo ~/codebase --test Some.UnitTest --gtest_filter=Specific\*
  ctest-slice.sh --repo ~/codebase --all --parallel
"
ARGS=""
ALL=""
PARALLEL=""

while [[ $# -gt 0 ]]; do
  case $1 in
    -r|--repo)
      WORKSPACE=$(realpath "${2}")
      shift
      shift
      ;;
    -a|--all)
      ALL="true"
      shift
      ;;
    -p|--parallel)
      PARALLEL="true"
      shift
      ;;
    -t|--test)
      TEST="${2}"
      shift
      shift
      ;;
    *)
      ARGS="${ARGS} ${1}"
      shift
      ;;
  esac
done

if [[ "${WORKSPACE}" == "" ]]
then
  WORKSPACE=$(pwd)
fi

if [ -z "${ALL}" ]
then
  if [[ "${TEST}" == "" ]]
  then
    fatal_error "-t|--test <TARGET> is a required argument"
  fi

  TESTS="${TEST}"
else
  cd "${WORKSPACE}/build"
  if [[ $? != 0 ]]
  then
    fatal_error "Build directory ${WORKSPACE}/build/ does not exist"
  fi

  TESTS=$(ctest -N | ag -o 'Test +#\d+: \K\N+')
  cd - 1>/dev/null
fi

cd "${WORKSPACE}/build"
cmake --build . --parallel 7 --target ${TESTS//$'\n'/ }
if [[ $? != 0 ]]
then
  fatal_error "Failed to build tests"
fi
cd - 1>/dev/null

LOGS=""
LOG_COUNT=0
for TEST in ${TESTS}
do
  WORK_DIR=$(find ${WORKSPACE}/build -name "${TEST}_work" | xargs dirname)
  LOG="${WORK_DIR}/${TEST}.log"
  LOGS="${LOGS} $(realpath ${LOG})"
  let "LOG_COUNT=LOG_COUNT+1"
done

# signal handler for SIGUSR1, kill fswatch when it is done
fswatch_done()
{
  local job_number=$(jobs %fswatch | ag -o '^\[\K\d+')
  kill "%${job_number}"
}
trap fswatch_done USR1

if [[ "${PARALLEL}" == "true" ]]
then
  # watch for file updates to the logs in the background
  # safe in this setup, files are only updated once, with their whole content
  RUN_COUNT=0
  fswatch -x --event Updated ${LOGS} | while read -r event
  do
    let "RUN_COUNT=RUN_COUNT+1"
    # strip off the events, we only want the file
    event=${event%% *}
    test_name=$(basename -s .log ${event})

    ag '\[  FAILED  \] \d+' ${event} >/dev/null
    if [[ $? -eq 0 ]]
    then
      echo -e "${RED}FAILED${NC}" ${RUN_COUNT}/${LOG_COUNT} "\t" ${test_name}
      ag -o '\[  FAILED  \] \K[a-zA-Z0-9.-_]+ \(\d+ ms\)' ${event} | tr '\n' '\0' | xargs -0 -n1 -I{} printf "  {}\n"
      echo "Logs here: ${event}"
    else
      echo -e "${GREEN}PASSED${NC}" ${RUN_COUNT}/${LOG_COUNT} "\t" ${test_name}
    fi

    if [[ ${RUN_COUNT} -eq ${LOG_COUNT} ]]
    then
      kill -s USR1 $$
    fi
  done &
fi

# execute tests
for TEST in ${TESTS}
do
  BIN="${WORKSPACE}/build/bin/${TEST}"
  if [[ ! -f ${BIN} ]]
  then
    fatal_error "Test executable ${BIN} does not exist"
  fi

  cd "${WORKSPACE}/build"
  WORK_DIR=$(find . -name "${TEST}_work" | xargs dirname)
  cd "${WORK_DIR}"
  if [[ $? != 0 ]]
  then
    fatal_error "Working directory ${WORK_DIR} does not exist"
  fi

  if [[ "${PARALLEL}" == "true" ]]
  then
    "${BIN}" ${ARGS} > "${TEST}.log" 2>&1 &
  else
    echo "${BIN} ${ARGS}"
    "${BIN}" ${ARGS}
    # TODO: check if the test failed?
  fi
done

if [[ "${PARALLEL}" == "true" ]]
then
  wait
fi
