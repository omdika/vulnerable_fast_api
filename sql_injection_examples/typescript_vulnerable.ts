/**
 * TypeScript SQL Injection Vulnerability Example
 *
 * ⚠️ WARNING: This code contains intentional SQL injection vulnerabilities
 * for educational and security research purposes only.
 */

import mysql from 'mysql2';

interface User {
    id: number;
    username: string;
    email: string;
    password: string;
}

class VulnerableTypeScript {
    private connection: mysql.Connection;

    constructor() {
        this.connection = mysql.createConnection({
            host: 'localhost',
            user: 'root',
            password: 'password',
            database: 'users_db'
        });
    }

    /**
     * VULNERABLE: SQL Injection through string concatenation
     */
    async vulnerableLogin(username: string, password: string): Promise<User | null> {
        return new Promise((resolve, reject) => {
            // VULNERABLE: Direct string concatenation
            const query = `SELECT * FROM users WHERE username = '${username}' AND password = '${password}'`;

            console.log(`Executing query: ${query}`);

            this.connection.query(query, (error, results: any) => {
                if (error) {
                    reject(error);
                } else {
                    resolve(results[0] || null);
                }
            });
        });
    }

    /**
     * VULNERABLE: SQL Injection in search functionality
     */
    async vulnerableSearch(searchTerm: string): Promise<User[]> {
        return new Promise((resolve, reject) => {
            // VULNERABLE: Unescaped user input in LIKE clause
            const query = `SELECT * FROM users WHERE username LIKE '%${searchTerm}%' OR email LIKE '%${searchTerm}%'`;

            console.log(`Executing search query: ${query}`);

            this.connection.query(query, (error, results: any) => {
                if (error) {
                    reject(error);
                } else {
                    resolve(results);
                }
            });
        });
    }

    /**
     * VULNERABLE: SQL Injection in INSERT statement
     */
    async vulnerableCreateUser(username: string, email: string, password: string): Promise<number> {
        return new Promise((resolve, reject) => {
            // VULNERABLE: Direct interpolation in INSERT
            const query = `INSERT INTO users (username, email, password) VALUES ('${username}', '${email}', '${password}')`;

            console.log(`Executing insert query: ${query}`);

            this.connection.query(query, (error, results: any) => {
                if (error) {
                    reject(error);
                } else {
                    resolve(results.insertId);
                }
            });
        });
    }

    /**
     * VULNERABLE: SQL Injection in DELETE statement
     */
    async vulnerableDeleteUser(userId: string): Promise<number> {
        return new Promise((resolve, reject) => {
            // VULNERABLE: Direct interpolation in DELETE
            const query = `DELETE FROM users WHERE id = ${userId}`;

            console.log(`Executing delete query: ${query}`);

            this.connection.query(query, (error, results: any) => {
                if (error) {
                    reject(error);
                } else {
                    resolve(results.affectedRows);
                }
            });
        });
    }

    /**
     * VULNERABLE: SQL Injection with multiple statements
     */
    async vulnerableMultiQuery(sqlInput: string): Promise<any[]> {
        return new Promise((resolve, reject) => {
            // VULNERABLE: Allows multiple statements
            const query = sqlInput;

            console.log(`Executing multi-query: ${query}`);

            this.connection.query({ sql: query, multipleStatements: true }, (error, results: any) => {
                if (error) {
                    reject(error);
                } else {
                    resolve(results);
                }
            });
        });
    }

    close(): void {
        this.connection.end();
    }
}

// Example usage demonstrating vulnerabilities
async function demonstrateVulnerabilities(): Promise<void> {
    console.log("TypeScript SQL Injection Vulnerable Code");
    console.log("=========================================");

    const vuln = new VulnerableTypeScript();

    try {
        // Test vulnerable login
        const testUser = "admin' OR '1'='1'--";
        const testPass = "anything";
        const loginResult = await vuln.vulnerableLogin(testUser, testPass);
        console.log("Login result:", loginResult);

        // Test vulnerable search
        const searchTerm = "test'; DROP TABLE users;--";
        const searchResults = await vuln.vulnerableSearch(searchTerm);
        console.log("Search results count:", searchResults.length);

        // Test vulnerable create
        const username = "newuser";
        const email = "test@example.com";
        const password = "password123";
        const createResult = await vuln.vulnerableCreateUser(username, email, password);
        console.log("Create result ID:", createResult);

        // Test vulnerable delete
        const userId = "1 OR 1=1";
        const deleteResult = await vuln.vulnerableDeleteUser(userId);
        console.log("Delete affected rows:", deleteResult);

        // Test multi-query injection
        const multiInput = "SELECT * FROM users; DROP TABLE users;--";
        const multiResults = await vuln.vulnerableMultiQuery(multiInput);
        console.log("Multi-query results:", multiResults);

    } catch (error) {
        console.error("Error:", error);
    } finally {
        vuln.close();
    }
}

// Run demonstration if this file is executed directly
if (require.main === module) {
    demonstrateVulnerabilities();
}

export { VulnerableTypeScript };