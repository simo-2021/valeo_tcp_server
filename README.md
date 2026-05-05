# Automotive ECU Simulator (TCP Server)

A robust TCP socket server programmed to simulate an automotive Electronic Control Unit (ECU). It generates synthetic CAN frames for vehicle diagnostics and handles network communications with system-level stability.

🚀 Key Features
Networking & Simulation
- TCP Server: Listens on port 9000 for incoming client connections.
- Multi-client Support: Handles multiple clients sequentially using an accept() loop.
- CAN Frame Generation: Simulates real-time physical values including RPM, speed, temperature, and pressure.
- Data Logging: Automatically saves all generated CAN data to /var/tmp/ecu_can_data.log.

System Integration
- Daemon Mode: Includes a -d flag to run the process in the background using daemon().
- System Logging: Integrates with syslog to track critical events (startup, shutdown, client connections, and errors).
- Signal Handling: Uses volatile sig_atomic_t for graceful shutdowns and resource cleanup (closing sockets, freeing memory).
- Socket Optimization: Implements setsockopt to manage communication timeouts and prevent hanging connections.

🛠 Technical Specifications
- Port: 9000
- Log Path: /var/tmp/ecu_can_data.log
- System Logs: Syslog (facility: LOG_USER/LOG_DAEMON)
- Execution: Foreground or Background (Daemon)
