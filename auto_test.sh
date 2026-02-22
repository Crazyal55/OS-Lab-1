#!/bin/bash

set -e

cd /home/alex/project1

echo "=== Automated Process Inspector Test ==="
echo ""

# Kill any existing processes
pkill -9 -f process_generator 2>/dev/null || true
sudo rmmod inspector 2>/dev/null || true

echo "Step 1: Starting process_generator..."
./process_generator > /tmp/pg_output.txt 2>&1 &
PG_PID=$!

# Wait for fork to happen
sleep 3

# Extract child PID from process tree (find process_generator whose parent is another process_generator)
CHILD_PID=$(ps -eo pid,ppid,comm | awk '$2 == '"$PG_PID"' && $3 == "process_generat" {print $1; exit}')

if [ -z "$CHILD_PID" ]; then
    echo "ERROR: Could not find child PID using ps"
    echo "Looking for process with parent $PG_PID..."
    ps -eo pid,ppid,comm | grep "$PG_PID"
    exit 1
fi

echo "✓ Parent PID: $PG_PID"
echo "✓ Child PID: $CHILD_PID"
echo ""

# Verify child is alive
if ! ps -p $CHILD_PID > /dev/null 2>&1; then
    echo "ERROR: Child process $CHILD_PID already exited!"
    exit 1
fi

echo "Step 2: Loading inspector module for PID $CHILD_PID..."
sudo rmmod inspector 2>/dev/null || true
sudo insmod inspector.ko target_pid=$CHILD_PID

echo ""
echo "Step 3: Checking kernel logs..."
echo "=== Recent kernel messages ==="
sudo dmesg | grep -A 20 "=== Inspector Module Loading ===" || sudo dmesg | tail -30

echo ""
echo "=== Checking if inspector loaded ==="
lsmod | grep inspector && echo "✓ Inspector module loaded!" || echo "✗ Inspector module NOT loaded"

echo ""
echo "Step 4: Waiting for process to finish (120 seconds)..."
sleep 10

# Show final logs
echo ""
echo "=== Final kernel logs ==="
sudo dmesg | grep -E "Inspector|PID|Process ancestry" | tail -30

echo ""
echo "Step 5: Cleanup"
sudo rmmod inspector 2>/dev/null || true
wait $PG_PID 2>/dev/null || true

echo ""
echo "=== Test Complete ==="
