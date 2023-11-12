#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>

#define MAX_BUFFER_SIZE 1024

void error(const char *msg) {
    perror(msg);
    exit(1);
}

int main(void) {
    const char *host = "i.kinja-img.com";
    const char *path = "/image/upload/c_fit,q_60,w_1315/b8af477bc10309189eda4edb777eb674.jpg";
    const char *filename = "/home/rogers/Desktop/downloaded_image.jpg";

    int sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if (sockfd < 0) {
        error("Error opening socket");
    }

    struct sockaddr_in server_addr;
    bzero((char *)&server_addr, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(80);

    struct hostent *server = gethostbyname(host);
    if (server == NULL) {
        fprintf(stderr, "Error, no such host\n");
        exit(1);
    }

    bcopy((char *)server->h_addr, (char *)&server_addr.sin_addr.s_addr, server->h_length);

    if (connect(sockfd, (struct sockaddr *)&server_addr, sizeof(server_addr)) < 0) {
        error("Error connecting to server");
    }

    char request[MAX_BUFFER_SIZE];
    snprintf(request, sizeof(request),
             "GET %s HTTP/1.1\r\n"
             "Host: %s\r\n"
             "Connection: close\r\n\r\n",
             path, host);

    if (write(sockfd, request, strlen(request)) < 0) {
        error("Error writing to socket");
    }

    FILE *image_file = fopen(filename, "wb");
    if (image_file == NULL) {
        error("Error opening image file");
    }

    char buffer[MAX_BUFFER_SIZE];
    int bytes_received;

    // Skip HTTP headers
    while ((bytes_received = read(sockfd, buffer, sizeof(buffer))) > 0) {
        if (strstr(buffer, "\r\n\r\n")) {
            break;
        }
    }

    // Receive and save the image data
    while ((bytes_received = read(sockfd, buffer, sizeof(buffer))) > 0) {
        fwrite(buffer, 1, bytes_received, image_file);
    }

    if (bytes_received < 0) {
        error("Error reading from socket");
    }

    printf("Image downloaded successfully!\n");

    close(sockfd);
    fclose(image_file);

    return 0;
}
