from sqlalchemy.orm import Session
from sqlalchemy import text
from . import models
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def get_user_by_username(db: Session, username: str):
    # VULNERABLE: SQL Injection through string concatenation
    query = f"SELECT * FROM users WHERE username = '{username}'"
    result = db.execute(text(query))
    return result.first()

def create_user(db: Session, username: str, password: str):
    hashed = pwd_context.hash(password)
    
    # VULNERABLE: SQL Injection in INSERT statement
    query = f"INSERT INTO users (username, hashed_password) VALUES ('{username}', '{hashed}')"
    db.execute(text(query))
    db.commit()
    
    # Get the created user (also vulnerable)
    get_query = f"SELECT * FROM users WHERE username = '{username}'"
    result = db.execute(text(get_query))
    return result.first()

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)

# ADDITIONAL MORE VULNERABLE FUNCTIONS
def search_users(db: Session, search_term: str):
    # VULNERABLE: More dangerous because it allows multiple statements
    query = f"SELECT * FROM users WHERE username LIKE '%{search_term}%' OR email LIKE '%{search_term}%'"
    result = db.execute(text(query))
    return result.fetchall()

def delete_user_by_username(db: Session, username: str):
    # VULNERABLE: SQL Injection in DELETE statement
    query = f"DELETE FROM users WHERE username = '{username}'"
    db.execute(text(query))
    db.commit()
    return {"message": "User deleted"}

def update_user_password(db: Session, username: str, new_password: str):
    # VULNERABLE: SQL Injection in UPDATE statement
    hashed = pwd_context.hash(new_password)
    query = f"UPDATE users SET hashed_password = '{hashed}' WHERE username = '{username}'"
    db.execute(text(query))
    db.commit()
    return {"message": "Password updated"}