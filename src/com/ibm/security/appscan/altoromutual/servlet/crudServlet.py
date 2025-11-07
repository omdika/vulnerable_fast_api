from sqlalchemy.orm import Session
from sqlalchemy import text
from . import models
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def get_user_by_username(db: Session, username: str):
    # FIXED: Use parameterized query to prevent SQL injection
    stmt = text("SELECT * FROM users WHERE username = :username")
    result = db.execute(stmt, {"username": username})
    return result.first()

def create_user(db: Session, username: str, password: str):
    hashed = pwd_context.hash(password)
    
    # FIXED: Use parameterized INSERT to prevent SQL injection
    insert_stmt = text("INSERT INTO users (username, hashed_password) VALUES (:username, :hashed)")
    db.execute(insert_stmt, {"username": username, "hashed": hashed})
    db.commit()
    
    # Get the created user (parameterized)
    get_stmt = text("SELECT * FROM users WHERE username = :username")
    result = db.execute(get_stmt, {"username": username})
    return result.first()

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)

# ADDITIONAL MORE VULNERABLE FUNCTIONS
def search_users(db: Session, search_term: str):
    # FIXED: Use parameterized LIKE pattern to avoid injection and multi-statement attacks
    pattern = f"%{search_term}%"
    stmt = text("SELECT * FROM users WHERE username LIKE :pattern OR email LIKE :pattern")
    result = db.execute(stmt, {"pattern": pattern})
    return result.fetchall()

def delete_user_by_username(db: Session, username: str):
    # FIXED: Use parameterized DELETE to prevent SQL injection
    stmt = text("DELETE FROM users WHERE username = :username")
    db.execute(stmt, {"username": username})
    db.commit()
    return {"message": "User deleted"}

def update_user_password(db: Session, username: str, new_password: str):
    # FIXED: Hash password as before and use parameterized UPDATE to prevent SQL injection
    hashed = pwd_context.hash(new_password)
    stmt = text("UPDATE users SET hashed_password = :hashed WHERE username = :username")
    db.execute(stmt, {"hashed": hashed, "username": username})
    db.commit()
    return {"message": "Password updated"}
