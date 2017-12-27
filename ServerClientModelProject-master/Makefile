CFLAGS += -Wall
LDFLAGS += -lcrypto

SRC := server.c

MD5_SRC := md5sum.c
MD5_OBJ := $(MD5_SRC:.c=.o)

TARGET := $(SRC:.c=)

.PHONY: all clean

all: clean $(TARGET) client.o

client.o: client.c
	cc -o client client.c

$(TARGET): $(MD5_OBJ) md5sum.h
	$(CC) $(CFLAGS) -o $@ $< $(SRC) $(LDFLAGS)

clean:
	rm -f client
	rm -f server
