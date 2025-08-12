// -----------------------------------------------------------------------------
// TCP Chat Server (Windows C++)
//
// This is the Windows-compatible version of the multi-client TCP chat server.
// It uses the Winsock API for network communication and std::thread for
// handling multiple clients.
//
// How to compile (using MinGW g++):
// g++ -o server.exe server_windows.cpp -pthread -lws2_32
//
// How to run:
// ./server.exe <port>
// e.g., ./server.exe 8080
// -----------------------------------------------------------------------------

#include <iostream>
#include <string>
#include <vector>
#include <thread>
#include <mutex>
#include <algorithm>
#include <winsock2.h>
#include <ws2tcpip.h>

// Link with the Winsock library
#pragma comment(lib, "ws2_32.lib")

// Mutex for protecting shared resources (the list of client sockets)
std::mutex clients_mutex;
// Vector to store the sockets of all connected clients
std::vector<SOCKET> client_sockets;

// --- Function Prototypes ---
void broadcast_message(const std::string &message, SOCKET sender_socket);
void handle_client(SOCKET client_socket);

/**
 * @brief Initializes the Winsock library.
 *
 * WSAStartup must be called to initialize Winsock before using any other
 * socket functions on Windows.
 * @return True if initialization is successful, false otherwise.
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
 * @brief Main function to start the server.
 */
int main(int argc, char *argv[]) {
    if (argc < 2) {
        std::cerr << "Usage: " << argv[0] << " <port>" << std::endl;
        return 1;
    }

    if (!InitializeWinsock()) {
        return 1;
    }

    int port = std::stoi(argv[1]);
    SOCKET server_socket = INVALID_SOCKET;
    struct sockaddr_in address;

    // --- Create server socket ---
    server_socket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (server_socket == INVALID_SOCKET) {
        std::cerr << "Socket creation failed with error: " << WSAGetLastError() << std::endl;
        WSACleanup();
        return 1;
    }

    address.sin_family = AF_INET;
    address.sin_addr.s_addr = INADDR_ANY; // Accept connections from any IP
    address.sin_port = htons(port);

    // --- Bind the socket ---
    if (bind(server_socket, (struct sockaddr *)&address, sizeof(address)) == SOCKET_ERROR) {
        std::cerr << "Bind failed with error: " << WSAGetLastError() << std::endl;
        closesocket(server_socket);
        WSACleanup();
        return 1;
    }

    // --- Listen for incoming connections ---
    if (listen(server_socket, SOMAXCONN) == SOCKET_ERROR) {
        std::cerr << "Listen failed with error: " << WSAGetLastError() << std::endl;
        closesocket(server_socket);
        WSACleanup();
        return 1;
    }

    std::cout << "Server listening on port " << port << "..." << std::endl;

    while (true) {
        SOCKET client_socket = accept(server_socket, NULL, NULL);
        if (client_socket == INVALID_SOCKET) {
            std::cerr << "Accept failed with error: " << WSAGetLastError() << std::endl;
            continue;
        }

        std::cout << "New client connected." << std::endl;

        // --- Add new client socket to the list ---
        {
            std::lock_guard<std::mutex> lock(clients_mutex);
            client_sockets.push_back(client_socket);
        }

        // --- Create a new thread to handle the client ---
        std::thread(handle_client, client_socket).detach();
    }

    // --- Cleanup ---
    closesocket(server_socket);
    WSACleanup();

    return 0;
}

/**
 * @brief Broadcasts a message to all clients except the sender.
 */
void broadcast_message(const std::string &message, SOCKET sender_socket) {
    std::lock_guard<std::mutex> lock(clients_mutex);
    for (SOCKET socket : client_sockets) {
        if (socket != sender_socket) {
            if (send(socket, message.c_str(), message.length(), 0) == SOCKET_ERROR) {
                std::cerr << "Send failed with error: " << WSAGetLastError() << std::endl;
            }
        }
    }
}

/**
 * @brief Handles communication with a single client.
 */
void handle_client(SOCKET client_socket) {
    char buffer[4096];
    std::string client_id = "Client " + std::to_string(client_socket);

    while (true) {
        int bytes_received = recv(client_socket, buffer, sizeof(buffer), 0);

        if (bytes_received > 0) {
            std::string message(buffer, bytes_received);
            std::string broadcast_msg = client_id + ": " + message;
            std::cout << "Broadcasting: " << broadcast_msg << std::endl;
            broadcast_message(broadcast_msg, client_socket);
        } else {
            std::cout << client_id << " disconnected." << std::endl;
            
            {
                std::lock_guard<std::mutex> lock(clients_mutex);
                client_sockets.erase(std::remove(client_sockets.begin(), client_sockets.end(), client_socket), client_sockets.end());
            }
            
            std::string disconnect_msg = client_id + " has left the chat.";
            broadcast_message(disconnect_msg, -1);
            
            closesocket(client_socket);
            break;
        }
    }
}
