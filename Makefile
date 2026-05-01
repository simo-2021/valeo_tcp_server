# Utilisez ?= pour permettre à Buildroot de fournir son compilateur
CC ?= $(CROSS_COMPILE)gcc
CFLAGS ?= -Wall -g

# IMPORTANT : Le nom doit correspondre à ce que votre fichier .mk cherche
TARGET = valeo_ivc_socket

SRC = valeo_ivc_socket.c

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) -o $(TARGET) $(SRC)

clean:
	rm -f $(TARGET)

distclean: clean
	rm -f *.o
