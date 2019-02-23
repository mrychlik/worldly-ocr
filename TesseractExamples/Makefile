CPPFLAGS = -std=c++11 -O0 -ggdb3 -fno-pretty-templates -ftemplate-depth=66000

LDFLAGS  = -lm -llept -ltesseract

PROGRAMS = $(patsubst %.cpp,%,$(wildcard main*.cpp))

all: $(PROGRAMS)


clean: 
	-rm $(PROGRAMS)
