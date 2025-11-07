/*
 * Swift SQL Injection Vulnerability Example
 *
 * ⚠️ WARNING: This code contains intentional SQL injection vulnerabilities
 * for educational and security research purposes only.
 */

import Foundation
import SQLite3

class VulnerableSwift {
    var db: OpaquePointer?

    init() {
        if sqlite3_open("users.db", &db) != SQLITE_OK {
            print("Error opening database")
        }
    }

    deinit {
        sqlite3_close(db)
    }

    /**
     * VULNERABLE: SQL Injection through string concatenation
     */
    func vulnerableLogin(username: String, password: String) -> Bool {
        // VULNERABLE: Direct string concatenation
        let query = "SELECT * FROM users WHERE username = '\(username)' AND password = '\(password)'"

        print("Executing query: \(query)")

        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            let result = sqlite3_step(statement) == SQLITE_ROW
            sqlite3_finalize(statement)
            return result
        }
        return false
    }

    /**
     * VULNERABLE: SQL Injection in search functionality
     */
    func vulnerableSearch(searchTerm: String) {
        // VULNERABLE: Unescaped user input in LIKE clause
        let query = "SELECT * FROM users WHERE username LIKE '%\(searchTerm)%' OR email LIKE '%\(searchTerm)%'"

        print("Executing search query: \(query)")

        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let username = String(cString: sqlite3_column_text(statement, 1))
                let email = String(cString: sqlite3_column_text(statement, 2))
                print("Found user: \(username), Email: \(email)")
            }
            sqlite3_finalize(statement)
        }
    }

    /**
     * VULNERABLE: SQL Injection in INSERT statement
     */
    func vulnerableCreateUser(username: String, email: String, password: String) -> Int64 {
        // VULNERABLE: Direct interpolation in INSERT
        let query = "INSERT INTO users (username, email, password) VALUES ('\(username)', '\(email)', '\(password)')"

        print("Executing insert query: \(query)")

        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                let lastId = sqlite3_last_insert_rowid(db)
                sqlite3_finalize(statement)
                return lastId
            }
            sqlite3_finalize(statement)
        }
        return -1
    }

    /**
     * VULNERABLE: SQL Injection in DELETE statement
     */
    func vulnerableDeleteUser(userId: String) -> Int32 {
        // VULNERABLE: Direct interpolation in DELETE
        let query = "DELETE FROM users WHERE id = \(userId)"

        print("Executing delete query: \(query)")

        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                let changes = sqlite3_changes(db)
                sqlite3_finalize(statement)
                return changes
            }
            sqlite3_finalize(statement)
        }
        return 0
    }

    /**
     * VULNERABLE: SQL Injection with exec
     */
    func vulnerableExecRaw(sqlInput: String) -> Bool {
        // VULNERABLE: Direct execution of user input
        print("Executing raw SQL: \(sqlInput)")

        return sqlite3_exec(db, sqlInput, nil, nil, nil) == SQLITE_OK
    }
}

// Example usage demonstrating vulnerabilities
func demonstrateVulnerabilities() {
    print("Swift SQL Injection Vulnerable Code")
    print("===================================")

    let vuln = VulnerableSwift()

    // Test vulnerable login
    let testUser = "admin' OR '1'='1'--"
    let testPass = "anything"
    let loginResult = vuln.vulnerableLogin(username: testUser, password: testPass)
    print("Login result: \(loginResult)")

    // Test vulnerable search
    let searchTerm = "test'; DROP TABLE users;--"
    vuln.vulnerableSearch(searchTerm: searchTerm)

    // Test vulnerable create
    let username = "newuser"
    let email = "test@example.com"
    let password = "password123"
    let createResult = vuln.vulnerableCreateUser(username: username, email: email, password: password)
    print("Create result ID: \(createResult)")

    // Test vulnerable delete
    let userId = "1 OR 1=1"
    let deleteResult = vuln.vulnerableDeleteUser(userId: userId)
    print("Delete affected rows: \(deleteResult)")

    // Test raw execution
    let rawSql = "SELECT * FROM users; DROP TABLE users;--"
    let rawResult = vuln.vulnerableExecRaw(sqlInput: rawSql)
    print("Raw execution result: \(rawResult)")
}

// Run demonstration if this file is executed directly
if CommandLine.arguments.count > 0 && CommandLine.arguments[0].contains("swift_vulnerable") {
    demonstrateVulnerabilities()
}