#!/bin/bash

# Bash SQL Injection Vulnerability Example
#
# ⚠️ WARNING: This code contains intentional SQL injection vulnerabilities
# for educational and security research purposes only.

# VULNERABLE: SQL Injection through string concatenation
vulnerable_login() {
    local username="$1"
    local password="$2"

    # VULNERABLE: Direct string concatenation
    local query="SELECT * FROM users WHERE username = '$username' AND password = '$password'"

    echo "Executing query: $query"

    # Using sqlite3 command line tool
    sqlite3 users.db "$query"

    # Check if we got any results
    if sqlite3 users.db "$query" | grep -q .; then
        echo "Login successful"
        return 0
    else
        echo "Login failed"
        return 1
    fi
}

# VULNERABLE: SQL Injection in search functionality
vulnerable_search() {
    local search_term="$1"

    # VULNERABLE: Unescaped user input in LIKE clause
    local query="SELECT * FROM users WHERE username LIKE '%$search_term%' OR email LIKE '%$search_term%'"

    echo "Executing search query: $query"

    sqlite3 users.db "$query"
}

# VULNERABLE: SQL Injection in INSERT statement
vulnerable_create_user() {
    local username="$1"
    local email="$2"
    local password="$3"

    # VULNERABLE: Direct interpolation in INSERT
    local query="INSERT INTO users (username, email, password) VALUES ('$username', '$email', '$password')"

    echo "Executing insert query: $query"

    sqlite3 users.db "$query"

    echo "User created"
}

# VULNERABLE: SQL Injection in DELETE statement
vulnerable_delete_user() {
    local user_id="$1"

    # VULNERABLE: Direct interpolation in DELETE
    local query="DELETE FROM users WHERE id = $user_id"

    echo "Executing delete query: $query"

    sqlite3 users.db "$query"

    echo "User deleted"
}

# VULNERABLE: SQL Injection with direct command execution
vulnerable_exec_raw() {
    local sql_input="$1"

    # VULNERABLE: Direct execution of user input
    echo "Executing raw SQL: $sql_input"

    sqlite3 users.db "$sql_input"
}

# Example usage demonstrating vulnerabilities
demonstrate_vulnerabilities() {
    echo "Bash SQL Injection Vulnerable Code"
    echo "=================================="

    # Test vulnerable login
    local test_user="admin' OR '1'='1'--"
    local test_pass="anything"
    vulnerable_login "$test_user" "$test_pass"

    # Test vulnerable search
    local search_term="test'; DROP TABLE users;--"
    vulnerable_search "$search_term"

    # Test vulnerable create
    local username="newuser"
    local email="test@example.com"
    local password="password123"
    vulnerable_create_user "$username" "$email" "$password"

    # Test vulnerable delete
    local user_id="1 OR 1=1"
    vulnerable_delete_user "$user_id"

    # Test raw execution
    local raw_sql="SELECT * FROM users; DROP TABLE users;--"
    vulnerable_exec_raw "$raw_sql"
}

# Run demonstration if this script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    demonstrate_vulnerabilities
fi