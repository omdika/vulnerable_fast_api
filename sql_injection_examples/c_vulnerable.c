/*
 * C SQL Injection Vulnerability Example
 *
 * ⚠️ WARNING: This code contains intentional SQL injection vulnerabilities
 * for educational and security research purposes only.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sqlite3.h>

/**
 * VULNERABLE: SQL Injection through string concatenation
 */
int vulnerable_login(sqlite3* db, const char* username, const char* password) {
    // VULNERABLE: Direct string concatenation
    char query[512];
    snprintf(query, sizeof(query),
             "SELECT * FROM users WHERE username = '%s' AND password = '%s'",
             username, password);

    printf("Executing query: %s\n", query);

    sqlite3_stmt* stmt;
    if (sqlite3_prepare_v2(db, query, -1, &stmt, NULL) == SQLITE_OK) {
        int result = (sqlite3_step(stmt) == SQLITE_ROW);
        sqlite3_finalize(stmt);
        return result;
    }
    return 0;
}

/**
 * VULNERABLE: SQL Injection in search functionality
 */
void vulnerable_search(sqlite3* db, const char* search_term) {
    // VULNERABLE: Unescaped user input in LIKE clause
    char query[512];
    snprintf(query, sizeof(query),
             "SELECT * FROM users WHERE username LIKE '%%%s%%' OR email LIKE '%%%s%%'",
             search_term, search_term);

    printf("Executing search query: %s\n", query);

    sqlite3_stmt* stmt;
    if (sqlite3_prepare_v2(db, query, -1, &stmt, NULL) == SQLITE_OK) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            const char* username = (const char*)sqlite3_column_text(stmt, 1);
            const char* email = (const char*)sqlite3_column_text(stmt, 2);
            printf("Found user: %s, Email: %s\n", username, email);
        }
        sqlite3_finalize(stmt);
    }
}

/**
 * VULNERABLE: SQL Injection in INSERT statement
 */
int vulnerable_create_user(sqlite3* db, const char* username, const char* email, const char* password) {
    // VULNERABLE: Direct interpolation in INSERT
    char query[512];
    snprintf(query, sizeof(query),
             "INSERT INTO users (username, email, password) VALUES ('%s', '%s', '%s')",
             username, email, password);

    printf("Executing insert query: %s\n", query);

    sqlite3_stmt* stmt;
    if (sqlite3_prepare_v2(db, query, -1, &stmt, NULL) == SQLITE_OK) {
        if (sqlite3_step(stmt) == SQLITE_DONE) {
            int last_id = sqlite3_last_insert_rowid(db);
            sqlite3_finalize(stmt);
            return last_id;
        }
        sqlite3_finalize(stmt);
    }
    return -1;
}

/**
 * VULNERABLE: SQL Injection in DELETE statement
 */
int vulnerable_delete_user(sqlite3* db, const char* user_id) {
    // VULNERABLE: Direct interpolation in DELETE
    char query[512];
    snprintf(query, sizeof(query), "DELETE FROM users WHERE id = %s", user_id);

    printf("Executing delete query: %s\n", query);

    sqlite3_stmt* stmt;
    if (sqlite3_prepare_v2(db, query, -1, &stmt, NULL) == SQLITE_OK) {
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
int vulnerable_exec_raw(sqlite3* db, const char* sql_input) {
    // VULNERABLE: Direct execution of user input
    printf("Executing raw SQL: %s\n", sql_input);

    char* error_message = NULL;
    int result = sqlite3_exec(db, sql_input, NULL, NULL, &error_message);

    if (error_message != NULL) {
        fprintf(stderr, "SQL error: %s\n", error_message);
        sqlite3_free(error_message);
    }

    return result;
}

int main() {
    printf("C SQL Injection Vulnerable Code\n");
    printf("===============================\n");

    sqlite3* db;
    if (sqlite3_open("users.db", &db) != SQLITE_OK) {
        fprintf(stderr, "Cannot open database: %s\n", sqlite3_errmsg(db));
        return 1;
    }

    // Test vulnerable login
    const char* test_user = "admin' OR '1'='1'--";
    const char* test_pass = "anything";
    int login_result = vulnerable_login(db, test_user, test_pass);
    printf("Login result: %d\n", login_result);

    // Test vulnerable search
    const char* search_term = "test'; DROP TABLE users;--";
    vulnerable_search(db, search_term);

    // Test vulnerable create
    const char* username = "newuser";
    const char* email = "test@example.com";
    const char* password = "password123";
    int create_result = vulnerable_create_user(db, username, email, password);
    printf("Create result ID: %d\n", create_result);

    // Test vulnerable delete
    const char* user_id = "1 OR 1=1";
    int delete_result = vulnerable_delete_user(db, user_id);
    printf("Delete affected rows: %d\n", delete_result);

    // Test raw execution
    const char* raw_sql = "SELECT * FROM users; DROP TABLE users;--";
    int raw_result = vulnerable_exec_raw(db, raw_sql);
    printf("Raw execution result: %d\n", raw_result);

    sqlite3_close(db);
    return 0;
}