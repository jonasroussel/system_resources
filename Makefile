OS = $(shell uname)
CC = gcc # C compiler
CFLAGS = -fPIC -Wall -Wextra -O2 -g # C flags
RM = rm -f # rm command

ifeq ($(OS),Darwin)
	LDFLAGS = -dynamiclib # linking flags
	TARGET_LIB = lib/build/libsysres-mac64.dylib # target lib
else
	LDFLAGS = -shared # linking flags
	TARGET_LIB = lib/build/libsysres-linux64.so # target lib
endif

SRCS = cpu.c memory.c  # source files
SRCS := $(addprefix lib/src/libsysres/, $(SRCS))
OBJS = $(SRCS:.c=.o)

.PHONY: all
all: ${TARGET_LIB}

$(TARGET_LIB): $(OBJS)
	$(CC) ${LDFLAGS} -o $@ $^

$(SRCS:.c=.d):%.d:%.c
	$(CC) $(CFLAGS) -MM $< >$@

include $(SRCS:.c=.d)

.PHONY: clean
clean:
	-${RM} ${OBJS} $(SRCS:.c=.d)

fclean: clean
	-${RM} ${TARGET_LIB}
