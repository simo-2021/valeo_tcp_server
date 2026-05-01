# 1. Définir le préfixe de cross-compilation (si lancé hors Buildroot)
# Vous devez avoir installé : sudo apt install gcc-aarch64-linux-gnu
CROSS_COMPILE ?= aarch64-linux-gnu-

# 2. Utiliser ?= pour permettre à Buildroot d'injecter son propre compilateur
CC ?= $(CROSS_COMPILE)gcc
CFLAGS ?= -Wall -g

# 3. Nom de l'exécutable (doit correspondre à votre fichier .mk)
TARGET = valeo_ivc_socket
SRC = valeo_ivc_socket.c

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) -o $(TARGET) $(SRC)

clean:
	rm -f $(TARGET)

distclean: clean
	rm -f *.o
