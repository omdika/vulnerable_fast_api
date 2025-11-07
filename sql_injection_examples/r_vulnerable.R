#
# R SQL Injection Vulnerability Example
#
# ⚠️ WARNING: This code contains intentional SQL injection vulnerabilities
# for educational and security research purposes only.
#

library(RSQLite)

# VULNERABLE: SQL Injection through string concatenation
vulnerable_login <- function(username, password) {
  # VULNERABLE: Direct string concatenation
  query <- sprintf("SELECT * FROM users WHERE username = '%s' AND password = '%s'",
                   username, password)

  cat("Executing query:", query, "\n")

  conn <- dbConnect(SQLite(), "users.db")
  result <- dbGetQuery(conn, query)
  dbDisconnect(conn)

  return(nrow(result) > 0)
}

# VULNERABLE: SQL Injection in search functionality
vulnerable_search <- function(search_term) {
  # VULNERABLE: Unescaped user input in LIKE clause
  query <- sprintf("SELECT * FROM users WHERE username LIKE '%%%s%%' OR email LIKE '%%%s%%'",
                   search_term, search_term)

  cat("Executing search query:", query, "\n")

  conn <- dbConnect(SQLite(), "users.db")
  result <- dbGetQuery(conn, query)
  dbDisconnect(conn)

  if (nrow(result) > 0) {
    cat("Found users:\n")
    print(result)
  } else {
    cat("No users found\n")
  }

  return(result)
}

# VULNERABLE: SQL Injection in INSERT statement
vulnerable_create_user <- function(username, email, password) {
  # VULNERABLE: Direct interpolation in INSERT
  query <- sprintf("INSERT INTO users (username, email, password) VALUES ('%s', '%s', '%s')",
                   username, email, password)

  cat("Executing insert query:", query, "\n")

  conn <- dbConnect(SQLite(), "users.db")
  result <- dbExecute(conn, query)
  dbDisconnect(conn)

  return(result)
}

# VULNERABLE: SQL Injection in DELETE statement
vulnerable_delete_user <- function(user_id) {
  # VULNERABLE: Direct interpolation in DELETE
  query <- sprintf("DELETE FROM users WHERE id = %s", user_id)

  cat("Executing delete query:", query, "\n")

  conn <- dbConnect(SQLite(), "users.db")
  result <- dbExecute(conn, query)
  dbDisconnect(conn)

  return(result)
}

# VULNERABLE: SQL Injection with dbSendStatement
vulnerable_exec_raw <- function(sql_input) {
  # VULNERABLE: Direct execution of user input
  cat("Executing raw SQL:", sql_input, "\n")

  conn <- dbConnect(SQLite(), "users.db")
  result <- dbExecute(conn, sql_input)
  dbDisconnect(conn)

  return(result)
}

# Example usage demonstrating vulnerabilities
demonstrate_vulnerabilities <- function() {
  cat("R SQL Injection Vulnerable Code\n")
  cat("===============================\n")

  # Test vulnerable login
  test_user <- "admin' OR '1'='1'--"
  test_pass <- "anything"
  login_result <- vulnerable_login(test_user, test_pass)
  cat("Login result:", login_result, "\n")

  # Test vulnerable search
  search_term <- "test'; DROP TABLE users;--"
  search_results <- vulnerable_search(search_term)

  # Test vulnerable create
  username <- "newuser"
  email <- "test@example.com"
  password <- "password123"
  create_result <- vulnerable_create_user(username, email, password)
  cat("Create affected rows:", create_result, "\n")

  # Test vulnerable delete
  user_id <- "1 OR 1=1"
  delete_result <- vulnerable_delete_user(user_id)
  cat("Delete affected rows:", delete_result, "\n")

  # Test raw execution
  raw_sql <- "SELECT * FROM users; DROP TABLE users;--"
  raw_result <- vulnerable_exec_raw(raw_sql)
  cat("Raw execution affected rows:", raw_result, "\n")
}

# Run demonstration if this file is executed directly
if (!interactive()) {
  demonstrate_vulnerabilities()
}