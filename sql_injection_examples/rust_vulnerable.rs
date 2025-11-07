/*
 * Rust SQL Injection Vulnerability Example
 *
 * ⚠️ WARNING: This code contains intentional SQL injection vulnerabilities
 * for educational and security research purposes only.
 */

use rusqlite::{Connection, Result};

struct VulnerableRust {
    conn: Connection,
}

impl VulnerableRust {
    fn new() -> Result<Self> {
        let conn = Connection::open("users.db")?;
        Ok(VulnerableRust { conn })
    }

    /**
     * VULNERABLE: SQL Injection through string concatenation
     */
    fn vulnerable_login(&self, username: &str, password: &str) -> Result<bool> {
        // VULNERABLE: Direct string concatenation
        let query = format!(
            "SELECT * FROM users WHERE username = '{}' AND password = '{}'",
            username, password
        );

        println!("Executing query: {}", query);

        let mut stmt = self.conn.prepare(&query)?;
        let user_exists = stmt.exists([])?;
        Ok(user_exists)
    }

    /**
     * VULNERABLE: SQL Injection in search functionality
     */
    fn vulnerable_search(&self, search_term: &str) -> Result<()> {
        // VULNERABLE: Unescaped user input in LIKE clause
        let query = format!(
            "SELECT * FROM users WHERE username LIKE '%{}%' OR email LIKE '%{}%'",
            search_term, search_term
        );

        println!("Executing search query: {}", query);

        let mut stmt = self.conn.prepare(&query)?;
        let user_iter = stmt.query_map([], |row| {
            Ok((
                row.get::<_, String>(1)?, // username
                row.get::<_, String>(2)?, // email
            ))
        })?;

        for user in user_iter {
            let (username, email) = user?;
            println!("Found user: {}, Email: {}", username, email);
        }
        Ok(())
    }

    /**
     * VULNERABLE: SQL Injection in UPDATE statement
     */
    fn vulnerable_update_password(&self, username: &str, new_password: &str) -> Result<usize> {
        // VULNERABLE: Direct interpolation in UPDATE
        let query = format!(
            "UPDATE users SET password = '{}' WHERE username = '{}'",
            new_password, username
        );

        println!("Executing update query: {}", query);

        let rows_affected = self.conn.execute(&query, [])?;
        Ok(rows_affected)
    }

    /**
     * VULNERABLE: SQL Injection in DELETE statement
     */
    fn vulnerable_delete_user(&self, user_id: &str) -> Result<usize> {
        // VULNERABLE: Direct interpolation in DELETE
        let query = format!("DELETE FROM users WHERE id = {}", user_id);

        println!("Executing delete query: {}", query);

        let rows_affected = self.conn.execute(&query, [])?;
        Ok(rows_affected)
    }

    /**
     * VULNERABLE: SQL Injection with execute_batch
     */
    fn vulnerable_execute_batch(&self, sql_input: &str) -> Result<()> {
        // VULNERABLE: Direct execution of user input
        println!("Executing batch: {}", sql_input);

        self.conn.execute_batch(sql_input)?;
        Ok(())
    }
}

fn main() -> Result<()> {
    println!("Rust SQL Injection Vulnerable Code");
    println!("===================================");

    let vuln = VulnerableRust::new()?;

    // Test vulnerable login
    let test_user = "admin' OR '1'='1'--";
    let test_pass = "anything";
    let login_result = vuln.vulnerable_login(test_user, test_pass)?;
    println!("Login result: {}", login_result);

    // Test vulnerable search
    let search_term = "test'; DROP TABLE users;--";
    vuln.vulnerable_search(search_term)?;

    // Test vulnerable update
    let username = "admin";
    let new_password = "hacked'; DROP TABLE users;--";
    let update_result = vuln.vulnerable_update_password(username, new_password)?;
    println!("Update affected rows: {}", update_result);

    // Test vulnerable delete
    let user_id = "1 OR 1=1";
    let delete_result = vuln.vulnerable_delete_user(user_id)?;
    println!("Delete affected rows: {}", delete_result);

    // Test batch execution
    let batch_sql = "SELECT * FROM users; DROP TABLE users;--";
    vuln.vulnerable_execute_batch(batch_sql)?;

    Ok(())
}