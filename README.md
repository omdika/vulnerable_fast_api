# vulnerable_fast_api

This example provides API endpoints with SQL injection vulnerabilities for research and learning purposes.

## Setup & Run (macOS)

1. Create virtual environment and install dependencies:
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```

2. Start the server:
   ```bash
   uvicorn app.main:app --reload
   ```

## Available Endpoints

Authentication:
- POST /register  
  ```json
  { "username": "test", "password": "test123" }
  ```
- POST /login     
  ```json
  { "username": "test", "password": "test123" }
  ```

User Management:
- GET /users/search?search_term={term}  
  Search users by username or email
- DELETE /users/{username}  
  Delete user by username
- PUT /users/{username}/password?new_password={password}  
  Update user password

## SQL Injection Vulnerability Examples

This repository now includes **20 different programming language examples** demonstrating SQL injection vulnerabilities for educational purposes:

### Programming Languages with SQL Injection Examples:

| Language | File | Database Library |
|----------|------|-----------------|
| **Python** | `sql_injection_examples/python_vulnerable.py` | sqlite3 |
| **Java** | `sql_injection_examples/java_vulnerable.java` | JDBC |
| **JavaScript** | `sql_injection_examples/javascript_vulnerable.js` | sqlite3 |
| **PHP** | `sql_injection_examples/php_vulnerable.php` | MySQLi |
| **C#** | `sql_injection_examples/csharp_vulnerable.cs` | SqlClient |
| **Ruby** | `sql_injection_examples/ruby_vulnerable.rb` | sqlite3 |
| **Go** | `sql_injection_examples/go_vulnerable.go` | go-sqlite3 |
| **Rust** | `sql_injection_examples/rust_vulnerable.rs` | rusqlite |
| **TypeScript** | `sql_injection_examples/typescript_vulnerable.ts` | mysql2 |
| **Perl** | `sql_injection_examples/perl_vulnerable.pl` | DBI |
| **Swift** | `sql_injection_examples/swift_vulnerable.swift` | SQLite3 |
| **Kotlin** | `sql_injection_examples/kotlin_vulnerable.kt` | JDBC |
| **Scala** | `sql_injection_examples/scala_vulnerable.scala` | JDBC |
| **C++** | `sql_injection_examples/cpp_vulnerable.cpp` | SQLite3 |
| **C** | `sql_injection_examples/c_vulnerable.c` | SQLite3 |
| **R** | `sql_injection_examples/r_vulnerable.R` | RSQLite |
| **PowerShell** | `sql_injection_examples/powershell_vulnerable.ps1` | System.Data.SQLite |
| **Bash** | `sql_injection_examples/bash_vulnerable.sh` | sqlite3 CLI |
| **Lua** | `sql_injection_examples/lua_vulnerable.lua` | lsqlite3 |
| **Dart** | `sql_injection_examples/dart_vulnerable.dart` | sqflite |

### Common Vulnerability Patterns Demonstrated:

- **String concatenation** in SQL queries
- **Unescaped user input** in WHERE clauses
- **Direct interpolation** in INSERT, UPDATE, DELETE statements
- **LIKE clause vulnerabilities** in search functionality
- **Raw SQL execution** from user input
- **Multiple statement execution** vulnerabilities

### Example Usage:

Each file demonstrates multiple vulnerable functions with example attack payloads:

```bash
# Example: Testing Python SQL injection
cd sql_injection_examples
python3 python_vulnerable.py
```

## Security Notice

⚠️ **WARNING**: This API and all example files contain **intentional SQL injection vulnerabilities** for research and educational purposes:
- String concatenation in SQL queries
- Unescaped user input in SQL statements
- Direct use of user input in queries

**DO NOT USE THIS CODE IN PRODUCTION.**

These examples are designed for:
- Security education and training
- Penetration testing practice
- Understanding SQL injection attack patterns
- Learning secure coding practices by contrast