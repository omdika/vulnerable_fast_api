/**
 * JavaScript SQL Injection Vulnerability Example
 *
 * ⚠️ WARNING: This code contains intentional SQL injection vulnerabilities
 * for educational and security research purposes only.
 */

const sqlite3 = require('sqlite3').verbose();

/**
 * VULNERABLE: SQL Injection through string concatenation
 */
function vulnerableLogin(username, password) {
    return new Promise((resolve, reject) => {
        const db = new sqlite3.Database('users.db');

        // VULNERABLE: Direct string concatenation
        const query = `SELECT * FROM users WHERE username = '${username}' AND password = '${password}'`;

        console.log(`Executing query: ${query}`);

        db.get(query, (err, row) => {
            if (err) {
                reject(err);
            } else {
                resolve(row);
            }
            db.close();
        });
    });
}

/**
 * VULNERABLE: SQL Injection in search functionality
 */
function vulnerableSearch(searchTerm) {
    return new Promise((resolve, reject) => {
        const db = new sqlite3.Database('users.db');

        // VULNERABLE: Unescaped user input in LIKE clause
        const query = `SELECT * FROM users WHERE username LIKE '%${searchTerm}%' OR email LIKE '%${searchTerm}%'`;

        console.log(`Executing search query: ${query}`);

        db.all(query, (err, rows) => {
            if (err) {
                reject(err);
            } else {
                resolve(rows);
            }
            db.close();
        });
    });
}

/**
 * VULNERABLE: SQL Injection in INSERT statement
 */
function vulnerableCreateUser(username, email, password) {
    return new Promise((resolve, reject) => {
        const db = new sqlite3.Database('users.db');

        // VULNERABLE: Direct interpolation in INSERT
        const query = `INSERT INTO users (username, email, password) VALUES ('${username}', '${email}', '${password}')`;

        console.log(`Executing insert query: ${query}`);

        db.run(query, function(err) {
            if (err) {
                reject(err);
            } else {
                resolve({ id: this.lastID });
            }
            db.close();
        });
    });
}

/**
 * VULNERABLE: SQL Injection in DELETE statement
 */
function vulnerableDeleteUser(userId) {
    return new Promise((resolve, reject) => {
        const db = new sqlite3.Database('users.db');

        // VULNERABLE: Direct interpolation in DELETE
        const query = `DELETE FROM users WHERE id = ${userId}`;

        console.log(`Executing delete query: ${query}`);

        db.run(query, function(err) {
            if (err) {
                reject(err);
            } else {
                resolve({ changes: this.changes });
            }
            db.close();
        });
    });
}

// Example usage demonstrating vulnerabilities
async function demonstrateVulnerabilities() {
    console.log("JavaScript SQL Injection Vulnerable Code");
    console.log("=========================================");

    try {
        // Test vulnerable login
        const testUser = "admin' OR '1'='1'--";
        const testPass = "anything";
        const loginResult = await vulnerableLogin(testUser, testPass);
        console.log("Login result:", loginResult);

        // Test vulnerable search
        const searchTerm = "test'; DROP TABLE users;--";
        const searchResults = await vulnerableSearch(searchTerm);
        console.log("Search results:", searchResults);

        // Test vulnerable create
        const username = "newuser";
        const email = "test@example.com";
        const password = "password123";
        const createResult = await vulnerableCreateUser(username, email, password);
        console.log("Create result:", createResult);

        // Test vulnerable delete
        const userId = "1 OR 1=1";
        const deleteResult = await vulnerableDeleteUser(userId);
        console.log("Delete result:", deleteResult);

    } catch (error) {
        console.error("Error:", error.message);
    }
}

// Run demonstration if this file is executed directly
if (require.main === module) {
    demonstrateVulnerabilities();
}

module.exports = {
    vulnerableLogin,
    vulnerableSearch,
    vulnerableCreateUser,
    vulnerableDeleteUser
};