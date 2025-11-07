#!/usr/bin/env python3
"""
Python SQL Injection Vulnerability Example

⚠️ WARNING: This code contains intentional SQL injection vulnerabilities
for educational and security research purposes only.
"""

import sqlite3

def vulnerable_login(username, password):
    """
    VULNERABLE: SQL Injection through string concatenation
    """
    conn = sqlite3.connect('users.db')
    cursor = conn.cursor()

    # VULNERABLE: Direct string concatenation
    query = f"SELECT * FROM users WHERE username = '{username}' AND password = '{password}'"

    print(f"Executing query: {query}")  # Debug output
    cursor.execute(query)

    user = cursor.fetchone()
    conn.close()
    return user

def vulnerable_search(search_term):
    """
    VULNERABLE: SQL Injection in search functionality
    """
    conn = sqlite3.connect('users.db')
    cursor = conn.cursor()

    # VULNERABLE: Unescaped user input in LIKE clause
    query = f"SELECT * FROM users WHERE username LIKE '%{search_term}%' OR email LIKE '%{search_term}%'"

    print(f"Executing search query: {query}")
    cursor.execute(query)

    results = cursor.fetchall()
    conn.close()
    return results

def vulnerable_delete_user(user_id):
    """
    VULNERABLE: SQL Injection in DELETE statement
    """
    conn = sqlite3.connect('users.db')
    cursor = conn.cursor()

    # VULNERABLE: Direct interpolation in DELETE
    query = f"DELETE FROM users WHERE id = {user_id}"

    print(f"Executing delete query: {query}")
    cursor.execute(query)
    conn.commit()
    conn.close()
    return f"Deleted user with ID: {user_id}"

if __name__ == "__main__":
    # Example usage demonstrating vulnerabilities
    print("SQL Injection Vulnerable Python Code")
    print("=" * 50)

    # Test vulnerable login
    test_user = "admin' OR '1'='1'--"
    test_pass = "anything"
    result = vulnerable_login(test_user, test_pass)
    print(f"Login result: {result}")

    # Test vulnerable search
    search_term = "test'; DROP TABLE users;--"
    search_results = vulnerable_search(search_term)
    print(f"Search results: {search_results}")

    # Test vulnerable delete
    user_id = "1 OR 1=1"
    delete_result = vulnerable_delete_user(user_id)
    print(f"Delete result: {delete_result}")