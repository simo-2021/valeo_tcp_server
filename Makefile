# Utilise le compilateur ARM si CROSS_COMPILE est défini, sinon gcc
CC = $(CROSS_COMPILE)gcc
CFLAGS = -Wall -g

valeo_ivc_socket: valeo_ivc_socket.c
	$(CC) $(CFLAGS) -o valeo_ivc_socket valeo_ivc_socket.c
