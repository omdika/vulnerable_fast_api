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

## Security Notice

⚠️ WARNING: This API contains intentional SQL injection vulnerabilities for research purposes:
- String concatenation in SQL queries
- Unescaped user input in SQL statements
- Direct use of user input in queries

DO NOT USE THIS CODE IN PRODUCTION.