/*
 * Scala SQL Injection Vulnerability Example
 *
 * ⚠️ WARNING: This code contains intentional SQL injection vulnerabilities
 * for educational and security research purposes only.
 */

import java.sql.{Connection, DriverManager, Statement}

class VulnerableScala {
  private val connection: Connection = DriverManager.getConnection("jdbc:sqlite:users.db")

  /**
   * VULNERABLE: SQL Injection through string concatenation
   */
  def vulnerableLogin(username: String, password: String): Boolean = {
    // VULNERABLE: Direct string concatenation
    val query = s"SELECT * FROM users WHERE username = '$username' AND password = '$password'"

    println(s"Executing query: $query")

    val statement: Statement = connection.createStatement()
    val resultSet = statement.executeQuery(query)
    val hasRows = resultSet.next()
    statement.close()
    hasRows
  }

  /**
   * VULNERABLE: SQL Injection in search functionality
   */
  def vulnerableSearch(searchTerm: String): Unit = {
    // VULNERABLE: Unescaped user input in LIKE clause
    val query = s"SELECT * FROM users WHERE username LIKE '%$searchTerm%' OR email LIKE '%$searchTerm%'"

    println(s"Executing search query: $query")

    val statement: Statement = connection.createStatement()
    val resultSet = statement.executeQuery(query)

    while (resultSet.next()) {
      val username = resultSet.getString("username")
      val email = resultSet.getString("email")
      println(s"Found user: $username, Email: $email")
    }
    statement.close()
  }

  /**
   * VULNERABLE: SQL Injection in INSERT statement
   */
  def vulnerableCreateUser(username: String, email: String, password: String): Int = {
    // VULNERABLE: Direct interpolation in INSERT
    val query = s"INSERT INTO users (username, email, password) VALUES ('$username', '$email', '$password')"

    println(s"Executing insert query: $query")

    val statement: Statement = connection.createStatement()
    val rowsAffected = statement.executeUpdate(query)
    statement.close()
    rowsAffected
  }

  /**
   * VULNERABLE: SQL Injection in DELETE statement
   */
  def vulnerableDeleteUser(userId: String): Int = {
    // VULNERABLE: Direct interpolation in DELETE
    val query = s"DELETE FROM users WHERE id = $userId"

    println(s"Executing delete query: $query")

    val statement: Statement = connection.createStatement()
    val rowsAffected = statement.executeUpdate(query)
    statement.close()
    rowsAffected
  }

  /**
   * VULNERABLE: SQL Injection with execute
   */
  def vulnerableExecuteRaw(sqlInput: String): Boolean = {
    // VULNERABLE: Direct execution of user input
    println(s"Executing raw SQL: $sqlInput")

    val statement: Statement = connection.createStatement()
    val result = statement.execute(sqlInput)
    statement.close()
    result
  }

  def close(): Unit = {
    connection.close()
  }
}

object VulnerableScalaApp extends App {
  println("Scala SQL Injection Vulnerable Code")
  println("====================================")

  val vuln = new VulnerableScala()

  try {
    // Test vulnerable login
    val testUser = "admin' OR '1'='1'--"
    val testPass = "anything"
    val loginResult = vuln.vulnerableLogin(testUser, testPass)
    println(s"Login result: $loginResult")

    // Test vulnerable search
    val searchTerm = "test'; DROP TABLE users;--"
    vuln.vulnerableSearch(searchTerm)

    // Test vulnerable create
    val username = "newuser"
    val email = "test@example.com"
    val password = "password123"
    val createResult = vuln.vulnerableCreateUser(username, email, password)
    println(s"Create affected rows: $createResult")

    // Test vulnerable delete
    val userId = "1 OR 1=1"
    val deleteResult = vuln.vulnerableDeleteUser(userId)
    println(s"Delete affected rows: $deleteResult")

    // Test raw execution
    val rawSql = "SELECT * FROM users; DROP TABLE users;--"
    val rawResult = vuln.vulnerableExecuteRaw(rawSql)
    println(s"Raw execution result: $rawResult")

  } finally {
    vuln.close()
  }
}