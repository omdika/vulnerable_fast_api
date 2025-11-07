/*
 * C++ SQL Injection Vulnerability Example
 *
 * ⚠️ WARNING: This code contains intentional SQL injection vulnerabilities
 * for educational and security research purposes only.
 */

#include <iostream>
#include <sqlite3.h>
#include <string>

class VulnerableCpp {
private:
    sqlite3* db;

public:
    VulnerableCpp() {
        if (sqlite3_open("users.db", &db) != SQLITE_OK) {
            std::cerr << "Error opening database: " << sqlite3_errmsg(db) << std::endl;
        }
    }

    ~VulnerableCpp() {
        sqlite3_close(db);
    }

    /**
     * VULNERABLE: SQL Injection through string concatenation
     */
    bool vulnerableLogin(const std::string& username, const std::string& password) {
        // VULNERABLE: Direct string concatenation
        std::string query = "SELECT * FROM users WHERE username = '" + username +
                           "' AND password = '" + password + "'";

        std::cout << "Executing query: " << query << std::endl;

        sqlite3_stmt* stmt;
        if (sqlite3_prepare_v2(db, query.c_str(), -1, &stmt, nullptr) == SQLITE_OK) {
            bool result = (sqlite3_step(stmt) == SQLITE_ROW);
            sqlite3_finalize(stmt);
            return result;
        }
        return false;
    }

    /**
     * VULNERABLE: SQL Injection in search functionality
     */
    void vulnerableSearch(const std::string& searchTerm) {
        // VULNERABLE: Unescaped user input in LIKE clause
        std::string query = "SELECT * FROM users WHERE username LIKE '%" + searchTerm +
                           "%' OR email LIKE '%" + searchTerm + "%'";

        std::cout << "Executing search query: " << query << std::endl;

        sqlite3_stmt* stmt;
        if (sqlite3_prepare_v2(db, query.c_str(), -1, &stmt, nullptr) == SQLITE_OK) {
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                const char* username = reinterpret_cast<const char*>(sqlite3_column_text(stmt, 1));
                const char* email = reinterpret_cast<const char*>(sqlite3_column_text(stmt, 2));
                std::cout << "Found user: " << username << ", Email: " << email << std::endl;
            }
            sqlite3_finalize(stmt);
        }
    }

    /**
     * VULNERABLE: SQL Injection in INSERT statement
     */
    int vulnerableCreateUser(const std::string& username, const std::string& email, const std::string& password) {
        // VULNERABLE: Direct interpolation in INSERT
        std::string query = "INSERT INTO users (username, email, password) VALUES ('" +
                           username + "', '" + email + "', '" + password + "')";

        std::cout << "Executing insert query: " << query << std::endl;

        sqlite3_stmt* stmt;
        if (sqlite3_prepare_v2(db, query.c_str(), -1, &stmt, nullptr) == SQLITE_OK) {
            if (sqlite3_step(stmt) == SQLITE_DONE) {
                int lastId = sqlite3_last_insert_rowid(db);
                sqlite3_finalize(stmt);
                return lastId;
            }
            sqlite3_finalize(stmt);
        }
        return -1;
    }

    /**
     * VULNERABLE: SQL Injection in DELETE statement
     */
    int vulnerableDeleteUser(const std::string& userId) {
        // VULNERABLE: Direct interpolation in DELETE
        std::string query = "DELETE FROM users WHERE id = " + userId;

        std::cout << "Executing delete query: " << query << std::endl;

        sqlite3_stmt* stmt;
        if (sqlite3_prepare_v2(db, query.c_str(), -1, &stmt, nullptr) == SQLITE_OK) {
            if (sqlite3_step(stmt) == SQLITE_DONE) {
                int changes = sqlite3_changes(db);
                sqlite3_finalize(stmt);
                return changes;
            }
            sqlite3_finalize(stmt);
        }
        return 0;
    }

    /**
     * VULNERABLE: SQL Injection with exec
     */
    bool vulnerableExecRaw(const std::string& sqlInput) {
        // VULNERABLE: Direct execution of user input
        std::cout << "Executing raw SQL: " << sqlInput << std::endl;

        char* errorMessage = nullptr;
        int result = sqlite3_exec(db, sqlInput.c_str(), nullptr, nullptr, &errorMessage);

        if (errorMessage) {
            std::cerr << "SQL error: " << errorMessage << std::endl;
            sqlite3_free(errorMessage);
        }

        return (result == SQLITE_OK);
    }
};

int main() {
    std::cout << "C++ SQL Injection Vulnerable Code" << std::endl;
    std::cout << "==================================" << std::endl;

    VulnerableCpp vuln;

    // Test vulnerable login
    std::string testUser = "admin' OR '1'='1'--";
    std::string testPass = "anything";
    bool loginResult = vuln.vulnerableLogin(testUser, testPass);
    std::cout << "Login result: " << (loginResult ? "true" : "false") << std::endl;

    // Test vulnerable search
    std::string searchTerm = "test'; DROP TABLE users;--";
    vuln.vulnerableSearch(searchTerm);

    // Test vulnerable create
    std::string username = "newuser";
    std::string email = "test@example.com";
    std::string password = "password123";
    int createResult = vuln.vulnerableCreateUser(username, email, password);
    std::cout << "Create result ID: " << createResult << std::endl;

    // Test vulnerable delete
    std::string userId = "1 OR 1=1";
    int deleteResult = vuln.vulnerableDeleteUser(userId);
    std::cout << "Delete affected rows: " << deleteResult << std::endl;

    // Test raw execution
    std::string rawSql = "SELECT * FROM users; DROP TABLE users;--";
    bool rawResult = vuln.vulnerableExecRaw(rawSql);
    std::cout << "Raw execution result: " << (rawResult ? "true" : "false") << std::endl;

    return 0;
}