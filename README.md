# SQLite Server with ws4sqlite

A lightweight SQLite database server for chat history with HTTP Basic Authentication.

## Setup

Run the setup script to install dependencies and create the database:

```bash
chmod +x setup_server_and_db.sh start_server.sh
./setup_server_and_db.sh
```

This creates:
- `chat_history.db` - SQLite database with chat_history table
- `chat_history.yaml` - Authentication configuration

## Start Server

```bash
./start_server.sh
```

Server runs on `http://0.0.0.0:12321`

## Authentication

Default credentials (change in `chat_history.yaml`):
- Username: `admin`
- Password: `YourSuperSecretPass123`

## Database Schema

```sql
CREATE TABLE chat_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    summary TEXT NOT NULL,
    tags TEXT,
    date TEXT NOT NULL,
    time TEXT NOT NULL
);
```

## API Usage

### Query Records

```bash
curl -u admin:YourSuperSecretPass123 \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"transaction": [{"query": "SELECT * FROM chat_history"}]}' \
  http://192.168.1.2:12321/chat_history
```

### Insert Record

```bash
curl -u admin:YourSuperSecretPass123 \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "transaction": [{
      "statement": "INSERT INTO chat_history (summary, tags, date, time) VALUES (:summary, :tags, :date, :time)",
      "values": {
        "summary": "Chat summary",
        "tags": "tag1, tag2",
        "date": "2025-10-29",
        "time": "14:30:00"
      }
    }]
  }' \
  http://192.168.1.2:12321/chat_history
```

### Filter by Date

```bash
curl -u admin:YourSuperSecretPass123 \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "transaction": [{
      "query": "SELECT * FROM chat_history WHERE date = :date",
      "values": {"date": "2025-10-29"}
    }]
  }' \
  http://192.168.1.2:12321/chat_history
```

## Requirements

- Ubuntu 24.04
- SQLite3
- ws4sqlite v0.16.3 (auto-installed by setup script)

## Firewall

Allow port 12321 for external access:

```bash
sudo ufw allow 12321/tcp
sudo ufw reload
```