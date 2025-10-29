#!/bin/bash

# Setup script for ws4sqlite server and database
# Ubuntu 24.04

echo "Setting up ws4sqlite server and database..."

# Check if sqlite3 is installed
if ! command -v sqlite3 &> /dev/null; then
    echo "SQLite3 not found. Installing..."
    sudo apt update
    sudo apt install -y sqlite3
else
    echo "SQLite3 is already installed."
fi

# Check if ws4sqlite is installed
if ! command -v ws4sqlite &> /dev/null; then
    echo "ws4sqlite not found. Downloading and installing..."
    
    # Detect architecture
    ARCH=$(uname -m)
    VERSION="v0.16.3"
    
    if [ "$ARCH" = "x86_64" ]; then
        DOWNLOAD_URL="https://github.com/proofrock/ws4sqlite/releases/download/${VERSION}/ws4sqlite-${VERSION}-linux-amd64.tar.gz"
    elif [ "$ARCH" = "aarch64" ]; then
        DOWNLOAD_URL="https://github.com/proofrock/ws4sqlite/releases/download/${VERSION}/ws4sqlite-${VERSION}-linux-arm64.tar.gz"
    else
        echo "Unsupported architecture: $ARCH"
        exit 1
    fi
    
    echo "Downloading from $DOWNLOAD_URL..."
    
    # Check if curl or wget is available
    if command -v curl &> /dev/null; then
        curl -L "$DOWNLOAD_URL" -o ws4sqlite.tar.gz
    elif command -v wget &> /dev/null; then
        wget "$DOWNLOAD_URL" -O ws4sqlite.tar.gz
    else
        echo "Error: Neither curl nor wget is installed."
        echo "Please install one of them: sudo apt install curl"
        exit 1
    fi
    
    if [ $? -ne 0 ]; then
        echo "Error downloading ws4sqlite!"
        exit 1
    fi
    
    # Extract the tar.gz file
    echo "Extracting ws4sqlite..."
    tar -xzf ws4sqlite.tar.gz
    
    if [ $? -ne 0 ]; then
        echo "Error extracting ws4sqlite!"
        rm -f ws4sqlite.tar.gz
        exit 1
    fi
    
    # Clean up tar file
    rm -f ws4sqlite.tar.gz
    
    # Make it executable
    chmod +x ws4sqlite
    
    # Move to /usr/local/bin (optional, requires sudo)
    echo "Installing to /usr/local/bin (requires sudo)..."
    sudo mv ws4sqlite /usr/local/bin/
    
    if [ $? -eq 0 ]; then
        echo "ws4sqlite installed successfully!"
    else
        echo "Could not move to /usr/local/bin. The binary is in the current directory."
        echo "You can run it with ./ws4sqlite"
    fi
else
    echo "ws4sqlite is already installed."
fi

# Create the database and table
DB_PATH="./chat_history.db"
CONFIG_PATH="./chat_history.yaml"

echo "Creating database at $DB_PATH..."

sqlite3 "$DB_PATH" <<EOF
CREATE TABLE IF NOT EXISTS chat_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    summary TEXT NOT NULL,
    tags TEXT,
    date TEXT NOT NULL,
    time TEXT NOT NULL
);
EOF

if [ $? -eq 0 ]; then
    echo "Database and table created successfully!"
    echo "Database location: $DB_PATH"
    
    # Verify table creation
    echo -e "\nVerifying table structure:"
    sqlite3 "$DB_PATH" ".schema chat_history"
else
    echo "Error creating database!"
    exit 1
fi

# Create companion config file with authentication
echo -e "\nCreating companion config file at $CONFIG_PATH..."

cat > "$CONFIG_PATH" <<'EOF'
auth:
  mode: HTTP
  byCredentials:
    - user: admin
      password: YourSuperSecretPass123
EOF

if [ $? -eq 0 ]; then
    echo "Config file created successfully!"
    echo "Default credentials: admin / YourSuperSecretPass123"
    echo "WARNING: Change the password in $CONFIG_PATH before deploying!"
else
    echo "Error creating config file!"
    exit 1
fi

echo -e "\nSetup complete!"
echo "You can now run ./start_server.sh to start the ws4sqlite server."