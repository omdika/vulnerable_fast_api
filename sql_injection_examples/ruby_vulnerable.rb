#!/usr/bin/env ruby

# Ruby SQL Injection Vulnerability Example
#
# ⚠️ WARNING: This code contains intentional SQL injection vulnerabilities
# for educational and security research purposes only.

require 'sqlite3'

class VulnerableRuby
  def initialize
    @db = SQLite3::Database.new('users.db')
  end

  # VULNERABLE: SQL Injection through string concatenation
  def vulnerable_login(username, password)
    # VULNERABLE: Direct string concatenation
    query = "SELECT * FROM users WHERE username = '#{username}' AND password = '#{password}'"

    puts "Executing query: #{query}"

    result = @db.execute(query)
    result.any?
  end

  # VULNERABLE: SQL Injection in search functionality
  def vulnerable_search(search_term)
    # VULNERABLE: Unescaped user input in LIKE clause
    query = "SELECT * FROM users WHERE username LIKE '%#{search_term}%' OR email LIKE '%#{search_term}%'"

    puts "Executing search query: #{query}"

    @db.execute(query)
  end

  # VULNERABLE: SQL Injection in INSERT statement
  def vulnerable_create_user(username, email, password)
    # VULNERABLE: Direct interpolation in INSERT
    query = "INSERT INTO users (username, email, password) VALUES ('#{username}', '#{email}', '#{password}')"

    puts "Executing insert query: #{query}"

    @db.execute(query)
    @db.changes
  end

  # VULNERABLE: SQL Injection in DELETE statement
  def vulnerable_delete_user(user_id)
    # VULNERABLE: Direct interpolation in DELETE
    query = "DELETE FROM users WHERE id = #{user_id}"

    puts "Executing delete query: #{query}"

    @db.execute(query)
    @db.changes
  end

  # VULNERABLE: SQL Injection with multiple statements
  def vulnerable_execute_raw_sql(sql_input)
    # VULNERABLE: Direct execution of user input
    query = sql_input

    puts "Executing raw SQL: #{query}"

    @db.execute_batch(query)
  end
end

# Example usage demonstrating vulnerabilities
def demonstrate_vulnerabilities
  puts "Ruby SQL Injection Vulnerable Code"
  puts "=================================="

  vuln = VulnerableRuby.new

  # Test vulnerable login
  test_user = "admin' OR '1'='1'--"
  test_pass = "anything"
  login_result = vuln.vulnerable_login(test_user, test_pass)
  puts "Login result: #{login_result}"

  # Test vulnerable search
  search_term = "test'; DROP TABLE users;--"
  search_results = vuln.vulnerable_search(search_term)
  puts "Search results count: #{search_results.length}"

  # Test vulnerable create
  username = "newuser"
  email = "test@example.com"
  password = "password123"
  create_result = vuln.vulnerable_create_user(username, email, password)
  puts "Create affected rows: #{create_result}"

  # Test vulnerable delete
  user_id = "1 OR 1=1"
  delete_result = vuln.vulnerable_delete_user(user_id)
  puts "Delete affected rows: #{delete_result}"

  # Test raw SQL execution
  raw_sql = "SELECT * FROM users; DROP TABLE users;--"
  vuln.vulnerable_execute_raw_sql(raw_sql)
  puts "Raw SQL executed"
end

# Run demonstration if this file is executed directly
if __FILE__ == $0
  demonstrate_vulnerabilities
end