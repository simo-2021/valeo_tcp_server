CC ?= $(CROSS_COMPILE)gcc
TARGET = valeo_ivc_socket

all: $(TARGET)

$(TARGET): valeo_ivc_socket.c
	$(CC) $(CFLAGS) -o $(TARGET) valeo_ivc_socket.c

clean:
	rm -f $(TARGET)
