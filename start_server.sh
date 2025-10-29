#!/bin/bash

# Start ws4sqlite server
# Ubuntu 24.04

DB_PATH="./chat_history.db"
BIND_HOST="0.0.0.0"
PORT="12321"

# Check if database exists
if [ ! -f "$DB_PATH" ]; then
    echo "Error: Database file not found at $DB_PATH"
    echo "Please run ./setup_server_and_db.sh first."
    exit 1
fi

# Check if ws4sqlite is installed
if ! command -v ws4sqlite &> /dev/null; then
    echo "Error: ws4sqlite is not installed."
    echo "Please run ./setup_server_and_db.sh first."
    exit 1
fi

echo "Starting ws4sqlite server..."
echo "Database: $DB_PATH"
echo "Bind host: $BIND_HOST"
echo "Port: $PORT"
echo ""
echo "Server will be accessible at http://$BIND_HOST:$PORT"
echo "Authentication: Enabled (check chat_history.yaml for credentials)"
echo "Press Ctrl+C to stop the server"
echo ""

# Start the server with the database file
# ws4sqlite will automatically load the companion config file (chat_history.yaml)
ws4sqlite -db "$DB_PATH" -bind-host "$BIND_HOST" -port "$PORT"