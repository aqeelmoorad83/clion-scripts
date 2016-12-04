#!/bin/sh

if [ $# -ne 2 ]; then
  echo "$0 <debug|release> <test-dir>"
  exit 1
fi
CONFIG=$1
if [ ${CONFIG} != debug -a ${CONFIG} != release ]; then
  echo "$0 <debug|release>"
  exit 1
fi
TESTDIR=$(echo $2 | sed 's#/##g')
CWD=$(pwd)
SCRIPTDIR="$(dirname -- "${0}")"
if [ ! -e cmake-build-${CONFIG} ]; then
  mkdir cmake-build-${CONFIG}
  cd cmake-build-${CONFIG}
  ${HOME}/clion-2016.3/bin/cmake/bin/cmake -DCMAKE_BUILD_TYPE=$(echo ${CONFIG} | perl -ane 'chomp;print ucfirst($_);') ..
  cd ..
fi
${HOME}/clion-2016.3/bin/cmake/bin/cmake --build cmake-build-${CONFIG} --target ${TESTDIR} -- -j 2
cmake-build-${CONFIG}/${TESTDIR}/${TESTDIR} --gtest_output=xml:cmake-build-${CONFIG}/${TESTDIR}/${TESTDIR}.xml
sed -i s#${CWD}/${TESTDIR}/##g cmake-build-${CONFIG}/${TESTDIR}/${TESTDIR}.xml
xsltproc ${SCRIPTDIR}/gtest.xsl cmake-build-${CONFIG}/${TESTDIR}/${TESTDIR}.xml > cmake-build-${CONFIG}/${TESTDIR}/${TESTDIR}.html
if [ $CONFIG = "debug" ]; then
  REPORT_DIR=cmake-build-debug/gcov-report
  PROJECT=$(basename ${CWD})
  rm -rf ${REPORT_DIR}
  PREFIX=cmake-build-debug/${TESTDIR}/CMakeFiles/${TESTDIR}
  (ls ${PREFIX}.dir/*.gcda 2>&1) > /dev/null
  if [ $? -eq 0 ]; then
    lcov -t ${TESTDIR} -o ${PREFIX}.info -c -d ${PREFIX}.dir
    lcov --remove ${PREFIX}.info '/usr/include/*' '6.2.0/*' -o ${PREFIX}-filtered.info
    mkdir -p ${REPORT_DIR}/${TESTDIR}
    genhtml -o ${REPORT_DIR}/${TESTDIR} ${PREFIX}-filtered.info
    COVERAGE_REPORT="${REPORT_DIR}/${TESTDIR}/${PROJECT}/index.html"
  fi
fi
FIREFOX_CMD="firefox cmake-build-${CONFIG}/${TESTDIR}/${TESTDIR}.html ${COVERAGE_REPORT}"
echo
echo "Running: ${FIREFOX_CMD}"
${FIREFOX_CMD}
echo
