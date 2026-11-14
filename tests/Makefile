CC ?= cc
.PHONY: all
all:
	$(CC) -std=c99 -Wall -Wextra -Werror -Isource source/avi.c tests/test_avi.c -o test-avi
	./test-avi
	rm -f test-avi avi-test.tmp
