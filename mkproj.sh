#!/bin/sh

if [ $# -ne 1 ]; then
	 echo "$0 <project-name>"
	 exit 1
fi
PROJ=$1

cd ${HOME}/ClionProjects

if [ -d ${PROJ} ]; then
	 echo "Project \"${PROJ}\" already exists"
	 exit 2
fi

mkdir ${PROJ}
cd ${PROJ}

cat > CMakeLists.txt <<EOF
cmake_minimum_required(VERSION 3.6)
project(foo)
include(CTest)

set(CMAKE_CXX_COMPILER "\$ENV{HOME}/gcc/bin/g++")
set(CMAKE_CXX_FLAGS "\${CMAKE_CXX_FLAGS} -Wall -Wextra -pedantic-errors -std=c++1z")
set(CMAKE_EXE_LINKER_FLAGS "\${CMAKE_EXE_LINKER_FLAGS} -Wl,-rpath \$ENV{HOME}/gcc/lib64")

file(GLOB CXX_SOURCES *.cpp)
add_executable(${PROJ} \${CXX_SOURCES})

add_subdirectory(unit-tests)
EOF

cat > main.cpp <<EOF
#include <iostream>
#include "mul.h"

int main()
{
  std::cout << "mul(10, 20) = " << mul(10, 20) << "\\n";
  return 0;
}
EOF

cat > mul.cpp <<EOF
#include "mul.h"

int mul(int x, int y)
{
  return x * y;
}
EOF

cat > mul.h <<EOF
#ifndef MUL_H
#define MUL_H

int mul(int, int);

#endif
EOF

mkdir -p unit-tests
cat > unit-tests/CMakeLists.txt <<EOF
find_package(GTest REQUIRED)
include_directories(\${GTEST_INCLUDE_DIRS})

if (CMAKE_BUILD_TYPE MATCHES Debug)
    set(CMAKE_CXX_FLAGS "\${CMAKE_CXX_FLAGS} -O0 -coverage")
endif ()

file(GLOB CXX_SOURCES *.cpp)
add_executable(unit-tests \${CXX_SOURCES})
target_link_libraries(unit-tests \${GTEST_BOTH_LIBRARIES} pthread)
add_test(unit-tests unit-tests)
EOF

cat > unit-tests/main.cpp <<EOF
#include <gtest/gtest.h>

int main(int argc, char **argv)
{
  testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}
EOF

cat > unit-tests/mulTests.cpp <<EOF
#include "../mul.cpp"
#include <gtest/gtest.h>

TEST(Multiply, Simple)
{
  ASSERT_EQ(200, mul(10, 20));
}
EOF
