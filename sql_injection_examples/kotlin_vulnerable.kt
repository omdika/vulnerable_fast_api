/*
 * Kotlin SQL Injection Vulnerability Example
 *
 * ⚠️ WARNING: This code contains intentional SQL injection vulnerabilities
 * for educational and security research purposes only.
 */

import java.sql.DriverManager

class VulnerableKotlin {
    private val connection = DriverManager.getConnection("jdbc:sqlite:users.db")

    /**
     * VULNERABLE: SQL Injection through string concatenation
     */
    fun vulnerableLogin(username: String, password: String): Boolean {
        // VULNERABLE: Direct string concatenation
        val query = "SELECT * FROM users WHERE username = '$username' AND password = '$password'"

        println("Executing query: $query")

        val statement = connection.createStatement()
        val resultSet = statement.executeQuery(query)
        return resultSet.next()
    }

    /**
     * VULNERABLE: SQL Injection in search functionality
     */
    fun vulnerableSearch(searchTerm: String) {
        // VULNERABLE: Unescaped user input in LIKE clause
        val query = "SELECT * FROM users WHERE username LIKE '%$searchTerm%' OR email LIKE '%$searchTerm%'"

        println("Executing search query: $query")

        val statement = connection.createStatement()
        val resultSet = statement.executeQuery(query)

        while (resultSet.next()) {
            val username = resultSet.getString("username")
            val email = resultSet.getString("email")
            println("Found user: $username, Email: $email")
        }
    }

    /**
     * VULNERABLE: SQL Injection in UPDATE statement
     */
    fun vulnerableUpdatePassword(username: String, newPassword: String): Int {
        // VULNERABLE: Direct interpolation in UPDATE
        val query = "UPDATE users SET password = '$newPassword' WHERE username = '$username'"

        println("Executing update query: $query")

        val statement = connection.createStatement()
        return statement.executeUpdate(query)
    }

    /**
     * VULNERABLE: SQL Injection in DELETE statement
     */
    fun vulnerableDeleteUser(userId: String): Int {
        // VULNERABLE: Direct interpolation in DELETE
        val query = "DELETE FROM users WHERE id = $userId"

        println("Executing delete query: $query")

        val statement = connection.createStatement()
        return statement.executeUpdate(query)
    }

    /**
     * VULNERABLE: SQL Injection with execute
     */
    fun vulnerableExecuteRaw(sqlInput: String): Boolean {
        // VULNERABLE: Direct execution of user input
        println("Executing raw SQL: $sqlInput")

        val statement = connection.createStatement()
        return statement.execute(sqlInput)
    }

    fun close() {
        connection.close()
    }
}

fun main() {
    println("Kotlin SQL Injection Vulnerable Code")
    println("====================================")

    val vuln = VulnerableKotlin()

    try {
        // Test vulnerable login
        val testUser = "admin' OR '1'='1'--"
        val testPass = "anything"
        val loginResult = vuln.vulnerableLogin(testUser, testPass)
        println("Login result: $loginResult")

        // Test vulnerable search
        val searchTerm = "test'; DROP TABLE users;--"
        vuln.vulnerableSearch(searchTerm)

        // Test vulnerable update
        val username = "admin"
        val newPassword = "hacked'; DROP TABLE users;--"
        val updateResult = vuln.vulnerableUpdatePassword(username, newPassword)
        println("Update affected rows: $updateResult")

        // Test vulnerable delete
        val userId = "1 OR 1=1"
        val deleteResult = vuln.vulnerableDeleteUser(userId)
        println("Delete affected rows: $deleteResult")

        // Test raw execution
        val rawSql = "SELECT * FROM users; DROP TABLE users;--"
        val rawResult = vuln.vulnerableExecuteRaw(rawSql)
        println("Raw execution result: $rawResult")

    } finally {
        vuln.close()
    }
}