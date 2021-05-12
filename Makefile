OS = $(shell uname -s | tr A-Z a-z)
ARCH = $(shell uname -m | tr A-Z a-z)
CC = gcc # C compiler
CFLAGS = -fPIC -Wall -Wextra -O2 -g # C flags
RM = rm -f # rm command
LDFLAGS = -shared # linking flags
TARGET_LIB := lib/build/libsysres-$(OS)-$(ARCH).so # target lib
SRCS = cpu.c memory.c  # source files
SRCS := $(addprefix lib/src/libsysres/, $(SRCS))
OBJS = $(SRCS:.c=.o)

ifeq ($(OS),darwin)
	LDFLAGS = -dynamiclib
	TARGET_LIB := lib/build/libsysres-$(OS)-$(ARCH).dylib
endif

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
