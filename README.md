# Automotive ECU Simulator (TCP Server)

A robust TCP socket server programmed to simulate an automotive Electronic Control Unit (ECU). It generates synthetic CAN frames for vehicle diagnostics and handles network communications with system-level stability.

🚀 Key Features
Networking & Simulation
- TCP Server: Listens on port 9000 for incoming client connections.
- Multi-client Support: Handles multiple clients sequentially using an accept() loop.
- CAN Frame Generation: Simulates real-time physical values including RPM, speed, temperature, and pressure.
- Data Logging: Automatically saves all generated CAN data to /var/tmp/ecu_can_data.log.
