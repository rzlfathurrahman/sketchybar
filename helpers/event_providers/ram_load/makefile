TARGET=bin/ram_load

all: $(TARGET)

$(TARGET): ram_load.c
	clang -std=c99 -O3 $< -o $@

clean:
	rm -f $(TARGET)

install: $(TARGET)

.PHONY: all clean install