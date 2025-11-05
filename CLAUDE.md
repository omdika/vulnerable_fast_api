# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **vulnerable FastAPI application** designed for security research and educational purposes. The application intentionally contains SQL injection vulnerabilities to demonstrate common security flaws in web applications.

**⚠️ SECURITY WARNING**: This code contains intentional vulnerabilities and should NEVER be used in production environments.

## Architecture

### Core Components

- **FastAPI Application** (`app/main.py`): Main application with API endpoints
- **Database Layer** (`app/database.py`): SQLAlchemy configuration using SQLite
- **Models** (`app/models.py`): SQLAlchemy ORM models (User model)
- **CRUD Operations** (`app/crud.py`): Database operations with intentional SQL injection vulnerabilities
- **Schemas** (`app/schemas.py`): Pydantic models for request/response validation

### Database Structure

- Uses SQLite database (`test.db`)
- Single `users` table with columns: `id`, `username`, `hashed_password`
- Password hashing using bcrypt via passlib

### Security Vulnerabilities

The application contains multiple intentional SQL injection vulnerabilities:

- **String concatenation** in SQL queries throughout `app/crud.py`
- **Unescaped user input** directly interpolated into SQL statements
- Vulnerable endpoints: user search, deletion, password updates
- Each CRUD function uses `f-string` interpolation instead of parameterized queries

## Development Commands

### Setup and Installation

```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

### Running the Application

```bash
# Start development server with auto-reload
uvicorn app.main:app --reload
```

### Testing

No test suite is currently implemented. The application is designed for manual security testing and vulnerability demonstration.

## API Endpoints

### Authentication
- `POST /register` - Create new user (vulnerable)
- `POST /login` - User authentication

### User Management (All Vulnerable)
- `GET /users/search?search_term={term}` - Search users by username/email
- `DELETE /users/{username}` - Delete user by username
- `PUT /users/{username}/password?new_password={password}` - Update user password

## Security Research Context

When working with this codebase:

- Focus on analyzing and demonstrating the vulnerabilities, not fixing them
- The vulnerabilities are intentionally designed for educational purposes
- Use this codebase to understand SQL injection attack vectors
- Document security findings and attack patterns

## Code Structure Notes

- All database operations are in `app/crud.py`
- Vulnerabilities use `text()` SQLAlchemy function with string interpolation
- No input sanitization or parameterized queries are used
- The application demonstrates common security anti-patterns