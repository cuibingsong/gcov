# 变量定义
CC = gcc
OBJDUMP = objdump
CFLAGS = -Wall -Werror -fprofile-arcs -ftest-coverage
LINK_LIBS = -lgcov
# 查找当前目录下的所有 .c 文件
SRCS = $(wildcard *.c)
# 将 .c 文件列表转换为 .o 文件列表
OBJS = $(SRCS:.c=.o)
# 可执行文件名
TARGET = main

ifeq ("$(origin V)", "command line")
  KBUILD_VERBOSE = $(V)
endif
ifndef KBUILD_VERBOSE
  KBUILD_VERBOSE = 0
endif

ifeq ($(KBUILD_VERBOSE),1)
  quiet =
  Q =
else
  quiet=quiet_
  Q = @
endif

# If the user is running make -s (silent mode), suppress echoing of
# commands
# make-4.0 (and later) keep single letter options in the 1st word of MAKEFLAGS.

ifeq ($(filter 3.%,$(MAKE_VERSION)),)
silence:=$(findstring s,$(firstword -$(MAKEFLAGS)))
else
silence:=$(findstring s,$(filter-out --%,$(MAKEFLAGS)))
endif

ifeq ($(silence),s)
quiet=silent_
endif

# 伪目标声明
.PHONY: all clean

# Convenient variables
comma   := ,
squote  := '
pound   := \#

# sink stdout for 'make -s'
       redirect :=
 quiet_redirect :=
silent_redirect := exec >/dev/null;

# Escape single quote for use in echo statements
escsq = $(subst $(squote),'\$(squote)',$1)

# Echo command
# Short version is used, if $(quiet) equals `quiet_', otherwise full one.
echo-cmd = $(if $($(quiet)cmd_$(1)), echo '  $(call escsq,$($(quiet)cmd_$(1)))';)
		   
#cmd = @set -e; $(echo-cmd) $($(quiet)redirect) $(delete-on-interrupt) $(cmd_$(1))
cmd = @set -e; $(echo-cmd) $($(quiet)redirect) $(cmd_$(1))

quiet_cmd_lcov = EXE LCOV
      cmd_lcov = lcov -c -d . -o test.info --rc lcov_branch_coverage=1 $(if $(quiet), > /dev/null 2>&1)
	  
quiet_cmd_genhtml = GEN HTML
      cmd_genhtml = genhtml --branch-coverage -o result test.info $(if $(quiet), > /dev/null 2>&1)

quiet_cmd_objdump = GEN $<.asm
      cmd_objdump = $(OBJDUMP) -S $< > $<.asm
	  
quiet_cmd_$(TARGET) = EXE $<
      cmd_$(TARGET) = ./$< $(if $(quiet), > /dev/null 2>&1)
# 默认目标
all: $(TARGET)
	$(call cmd,$(TARGET))
	$(call cmd,objdump)
	$(call cmd,lcov)
	$(call cmd,genhtml)
	
quiet_cmd_link = LINK $@
      cmd_link = $(CC) $^ $(LINK_LIBS) -o $(TARGET)
# 链接所有对象文件生成目标文件
$(TARGET): $(OBJS)
	$(call cmd,link)

quiet_cmd_cc = CC $@
      cmd_cc = $(CC) $(CFLAGS) -c $< -o $@
# 编译规则：每个源文件编译成对象文件
%.o: %.c
	$(call cmd,cc)

# clean 目标：删除所有以 main 开头的文件，除了 main.c
clean:
	$(Q)rm -f $(OBJS) $(TARGET) *.gcda *.gcno $(TARGET).asm test.info
	$(Q)rm -rf result

