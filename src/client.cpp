// -----------------------------------------------------------------------------
// TCP Chat Client (Windows C++)
//
// This is the Windows-compatible version of the TCP chat client.
// It uses the Winsock API to connect to the server and std::thread
// to handle sending and receiving messages concurrently.
//
// How to compile (using MinGW g++):
// g++ -o client.exe client_windows.cpp -pthread -lws2_32
//
// How to run:
// ./client.exe <server_ip> <port>
// e.g., ./client.exe 127.0.0.1 8080
// -----------------------------------------------------------------------------

#include <iostream>
#include <string>
#include <thread>
#include <winsock2.h>
#include <ws2tcpip.h>

// Link with the Winsock library
#pragma comment(lib, "ws2_32.lib")

// --- Function Prototypes ---
void receive_messages(SOCKET sock);
void send_messages(SOCKET sock);

/**
 * @brief Initializes the Winsock library.
 */
bool InitializeWinsock() {
    WSADATA wsaData;
    if (WSAStartup(MAKEWORD(2, 2), &wsaData) != 0) {
        std::cerr << "WSAStartup failed." << std::endl;
        return false;
    }
    return true;
}

/**
 * @brief Main function to start the client.
 */
int main(int argc, char *argv[]) {
    if (argc < 3) {
        std::cerr << "Usage: " << argv[0] << " <server_ip> <port>" << std::endl;
        return 1;
    }

    if (!InitializeWinsock()) {
        return 1;
    }

    const char* server_ip = argv[1];
    int port = std::stoi(argv[2]);
    SOCKET sock = INVALID_SOCKET;
    struct sockaddr_in serv_addr;

    // --- Create client socket ---
    sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (sock == INVALID_SOCKET) {
        std::cerr << "Socket creation failed with error: " << WSAGetLastError() << std::endl;
        WSACleanup();
        return 1;
    }

    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port = htons(port);

    // --- Convert IP address from text to binary form ---
    if (inet_pton(AF_INET, server_ip, &serv_addr.sin_addr) <= 0) {
        std::cerr << "Invalid address/ Address not supported" << std::endl;
        closesocket(sock);
        WSACleanup();
        return 1;
    }

    // --- Connect to the server ---
    if (connect(sock, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) == SOCKET_ERROR) {
        std::cerr << "Connection Failed with error: " << WSAGetLastError() << std::endl;
        closesocket(sock);
        WSACleanup();
        return 1;
    }

    std::cout << "Connected to the server. You can start chatting!" << std::endl;
    std::cout << "Type your message and press Enter to send." << std::endl;

    // --- Create threads for sending and receiving messages ---
    std::thread receive_thread(receive_messages, sock);
    std::thread send_thread(send_messages, sock);

    // --- Wait for threads to finish ---
    send_thread.join();
    receive_thread.detach();

    // --- Cleanup ---
    closesocket(sock);
    WSACleanup();
    return 0;
}

/**
 * @brief Listens for and prints messages from the server.
 */
void receive_messages(SOCKET sock) {
    char buffer[4096];
    while (true) {
        int bytes_received = recv(sock, buffer, sizeof(buffer), 0);
        if (bytes_received > 0) {
            std::cout << "\r" << std::string(buffer, bytes_received) << std::endl << "> " << std::flush;
        } else {
            std::cout << "Server closed the connection." << std::endl;
            break;
        }
    }
}

/**
 * @brief Reads user input and sends it to the server.
 */
void send_messages(SOCKET sock) {
    std::string line;
    std::cout << "> " << std::flush;
    while (std::getline(std::cin, line)) {
        if (!line.empty()) {
            if (send(sock, line.c_str(), line.length(), 0) == SOCKET_ERROR) {
                std::cerr << "Send failed with error: " << WSAGetLastError() << std::endl;
                break;
            }
        }
        std::cout << "> " << std::flush;
    }
}
