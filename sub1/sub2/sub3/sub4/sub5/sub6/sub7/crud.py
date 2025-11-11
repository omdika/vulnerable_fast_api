from sqlalchemy.orm import Session
from sqlalchemy import text
from . import models
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def get_user_by_username(db: Session, username: str):
    # Use parameterized query to prevent SQL injection
    query = text("SELECT * FROM users WHERE username = :username")
    result = db.execute(query, {"username": username})
    return result.first()

def create_user(db: Session, username: str, password: str):
    hashed = pwd_context.hash(password)
    
    # Use parameterized INSERT to avoid injecting values into SQL text
    query = text("INSERT INTO users (username, hashed_password) VALUES (:username, :hashed)")
    db.execute(query, {"username": username, "hashed": hashed})
    db.commit()
    
    # Get the created user safely using a parameterized query
    get_query = text("SELECT * FROM users WHERE username = :username")
    result = db.execute(get_query, {"username": username})
    return result.first()

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)

# ADDITIONAL MORE SAFE FUNCTIONS
def search_users(db: Session, search_term: str):
    # Parameterize the LIKE pattern; include wildcards in the bound parameter
    query = text("SELECT * FROM users WHERE username LIKE :term OR email LIKE :term")
    term = f"%{search_term}%"
    result = db.execute(query, {"term": term})
    return result.fetchall()

def delete_user_by_username(db: Session, username: str):
    # Parameterized DELETE to prevent SQL injection
    query = text("DELETE FROM users WHERE username = :username")
    db.execute(query, {"username": username})
    db.commit()
    return {"message": "User deleted"}

def update_user_password(db: Session, username: str, new_password: str):
    # Parameterized UPDATE
    hashed = pwd_context.hash(new_password)
    query = text("UPDATE users SET hashed_password = :hashed WHERE username = :username")
    db.execute(query, {"hashed": hashed, "username": username})
    db.commit()
    return {"message": "Password updated"}
