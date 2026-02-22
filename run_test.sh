#!/bin/bash

echo "=== Starting Process Generator ==="
cd /home/alex/project1

# Run process_generator in background and capture PID
./process_generator &
PG_PID=$!
PG_CHILD_PID=""
echo "Process generator PID: $PG_PID"

# Wait for output to appear with child PID
sleep 2

# Get child PID from log file (if process_generator wrote it)
if [ -f /tmp/pg_output.log ]; then
    PG_CHILD_PID=$(grep -oP 'Child running with PID: \K\d+' /tmp/pg_output.log | head -1)
fi

# If not in log, try to find child by parent relationship
if [ -z "$PG_CHILD_PID" ]; then
    # Look for process_generator that's a child of the parent
    PG_CHILD_PID=$(ps -eo pid,ppid,comm | grep "process_generat" | grep " $PG_PID" | awk '{print $1}' | head -1)
fi

echo "Found child PID: $PG_CHILD_PID"

if [ -z "$PG_CHILD_PID" ]; then
    echo "ERROR: Could not find child PID"
    exit 1
fi

echo ""
echo "=== Loading Inspector Module ==="
echo "Child PID: $PG_CHILD_PID"
echo "Loading inspector module..."

# Load inspector module
sudo rmmod inspector 2>/dev/null
sudo insmod inspector.ko target_pid=$PG_CHILD_PID

echo ""
echo "=== Checking Kernel Logs ==="
sudo dmesg | grep -E "PID:|Process ancestry" | tail -15

echo ""
echo "=== Cleanup ==="
echo "Unloading inspector module..."
sudo rmmod inspector

echo "Waiting for child process to finish..."
wait $PG_PID 2>/dev/null

echo "Done!"
