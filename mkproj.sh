#!/bin/sh

if [ $# -ne 1 ]; then
	 echo "$0 <project-name>"
	 exit 1
fi
PROJ=$1

if [ -d ${PROJ} ]; then
	 echo "Project \"${PROJ}\" already exists"
	 exit 2
fi

mkdir ${PROJ}
cd ${PROJ}

cat > CMakeLists.txt <<EOF
cmake_minimum_required(VERSION 3.6)
set(CMAKE_CXX_COMPILER "\$ENV{HOME}/gcc/bin/g++")  # needs to be before project()
project(${PROJ})
include(CTest)

set(CMAKE_CXX_FLAGS "\${CMAKE_CXX_FLAGS} -Wall -Wextra -pedantic-errors -std=c++1z")
set(CMAKE_EXE_LINKER_FLAGS "\${CMAKE_EXE_LINKER_FLAGS} -Wl,-rpath,\$ENV{HOME}/gcc/lib64")
#set(CMAKE_VERBOSE_MAKEFILE ON)

file(GLOB CXX_SOURCES *.cpp)
add_executable(${PROJ} \${CXX_SOURCES})

add_subdirectory("../googletest-release-1.8.0/googlemock" "\${CMAKE_CURRENT_BINARY_DIR}/gmock")
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
if (CMAKE_BUILD_TYPE MATCHES Debug)
    set(CMAKE_CXX_FLAGS "\${CMAKE_CXX_FLAGS} -O0 -coverage")
endif ()

file(GLOB CXX_SOURCES *.cpp)
add_executable(unit-tests \${CXX_SOURCES})
target_link_libraries(unit-tests gtest gmock)
add_test(unit-tests unit-tests)
EOF

cat > unit-tests/main.cpp <<EOF
#include <gmock/gmock.h>

int main(int argc, char **argv)
{
  testing::InitGoogleMock(&argc, argv);
  return RUN_ALL_TESTS();
}
EOF

cat > unit-tests/mulTests.cpp <<EOF
#include <gtest/gtest.h>
#include "../mul.cpp"

TEST(Multiply, verifySimpleMultiplication)
{
  ASSERT_EQ(200, mul(10, 20));
}
EOF

cat > unit-tests/seq.h <<EOF
#ifndef SEQ_H
#define SEQ_H

#include <initializer_list>
#include <stdexcept>

// An ersatz pointerish thing that enables a mocked method to return a predefined sequence.
//
// virtual X& getX() = 0;
// virtual int getY() = 0;
//   :
// X a(10), b(20), c(30), d(40);
// NiceMock<MockTurtle> turtle;
// ON_CALL(turtle, getX()).WillByDefault(ReturnPointee(Seq<X *>{&a, &b, &c, &d}));
// ON_CALL(turtle, getY()).WillByDefault(ReturnPointee(Seq<int>{23, 42, 64, 75}));
//
namespace testing {
  template<typename T>
  class Seq {
    using Iter = typename std::initializer_list<T>::const_iterator;
    mutable Iter m_it;
    const Iter m_end;
  public:
    explicit Seq(std::initializer_list<T> init) : m_it(init.begin()), m_end(init.end()) { }
    T operator*() const
    {
      if (m_it == m_end) { throw std::runtime_error("Falling off the end of Seq"); }
      return *m_it++;
    }
  };
  template<typename T>
  class Seq<T *> {
    using Iter = typename std::initializer_list<T *>::iterator;
    mutable Iter m_it;
    const Iter m_end;
  public:
    explicit Seq(std::initializer_list<T *> init) : m_it(init.begin()), m_end(init.end()) { }
    T& operator*() const
    {
      if (m_it == m_end) { throw std::runtime_error("Falling off the end of Seq"); }
      return **m_it++;
    }
  };
}

#endif
EOF
