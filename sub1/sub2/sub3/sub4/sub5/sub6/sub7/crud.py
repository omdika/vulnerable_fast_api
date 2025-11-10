from sqlalchemy.orm import Session
from sqlalchemy import text
from . import models
from passlib.context import CryptContext
import re

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# Server-side validation rules
USERNAME_REGEX = re.compile(r"^[A-Za-z0-9_.-]{1,150}$")
MAX_SEARCH_TERM_LENGTH = 100
MIN_PASSWORD_LENGTH = 8
MAX_PASSWORD_LENGTH = 128


def validate_username(username: str):
    if not isinstance(username, str):
        raise ValueError("username must be a string")
    if not USERNAME_REGEX.match(username):
        raise ValueError("username contains invalid characters or is too long")
    return username


def validate_password(password: str):
    if not isinstance(password, str):
        raise ValueError("password must be a string")
    if not (MIN_PASSWORD_LENGTH <= len(password) <= MAX_PASSWORD_LENGTH):
        raise ValueError("password length must be between %d and %d" % (MIN_PASSWORD_LENGTH, MAX_PASSWORD_LENGTH))
    return password


def validate_search_term(term: str):
    if not isinstance(term, str):
        raise ValueError("search term must be a string")
    if len(term) > MAX_SEARCH_TERM_LENGTH:
        raise ValueError("search term too long")
    # Disallow characters that could be used for SQL control if passed incorrectly
    if ";" in term or "--" in term:
        raise ValueError("search term contains invalid characters")
    return term


def get_user_by_username(db: Session, username: str):
    """Retrieve a user by username using a parameterized query to avoid SQL injection."""
    validate_username(username)
    query = text("SELECT * FROM users WHERE username = :username")
    result = db.execute(query, {"username": username})
    return result.first()


def create_user(db: Session, username: str, password: str):
    """Create a user using parameter binding. Password is hashed before being stored."""
    validate_username(username)
    validate_password(password)
    hashed = pwd_context.hash(password)

    query = text("INSERT INTO users (username, hashed_password) VALUES (:username, :hashed)")
    db.execute(query, {"username": username, "hashed": hashed})
    db.commit()

    get_query = text("SELECT * FROM users WHERE username = :username")
    result = db.execute(get_query, {"username": username})
    return result.first()


def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)


def search_users(db: Session, search_term: str):
    """Search users safely using a parameterized LIKE clause. Input is validated and wildcards are bound as parameters."""
    term = validate_search_term(search_term)
    like_term = f"%{term}%"
    query = text("SELECT * FROM users WHERE username LIKE :term OR email LIKE :term")
    result = db.execute(query, {"term": like_term})
    return result.fetchall()


def delete_user_by_username(db: Session, username: str):
    """Delete a user by username using parameter binding."""
    validate_username(username)
    query = text("DELETE FROM users WHERE username = :username")
    db.execute(query, {"username": username})
    db.commit()
    return {"message": "User deleted"}


def update_user_password(db: Session, username: str, new_password: str):
    """Update a user's password using parameter binding and server-side validation."""
    validate_username(username)
    validate_password(new_password)
    hashed = pwd_context.hash(new_password)
    query = text("UPDATE users SET hashed_password = :hashed WHERE username = :username")
    db.execute(query, {"hashed": hashed, "username": username})
    db.commit()
    return {"message": "Password updated"}
