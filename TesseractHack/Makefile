CXXFLAGS = -std=c++17 -O0 -g -ggdb -Wall -Wextra -pedantic-errors

# NOTE: -lstdc++fs is needed for GCC as the filesystem header is implemented as a library
LDFLAGS  = -lm -llept -ltesseract -lstdc++fs

PROGRAMS = $(patsubst %.cpp,%,$(wildcard main*.cpp))

all: $(PROGRAMS)

# This is needed because of the dependency on a static library libstdc++fs
# which implements header <filesystem> in current GCC (8). Will go away in GCC 9.XXX
main1: main1.cpp
	$(CXX) $(CXXFLAGS) $< -o $@ $(LDFLAGS)

clean: 
	-rm $(PROGRAMS)
