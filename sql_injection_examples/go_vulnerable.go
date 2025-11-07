package main

import (
	"database/sql"
	"fmt"
	_ "github.com/mattn/go-sqlite3"
)

/**
 * Go SQL Injection Vulnerability Example
 *
 * ⚠️ WARNING: This code contains intentional SQL injection vulnerabilities
 * for educational and security research purposes only.
 */

type VulnerableGo struct {
	db *sql.DB
}

func NewVulnerableGo() (*VulnerableGo, error) {
	db, err := sql.Open("sqlite3", "users.db")
	if err != nil {
		return nil, err
	}
	return &VulnerableGo{db: db}, nil
}

/**
 * VULNERABLE: SQL Injection through string concatenation
 */
func (v *VulnerableGo) VulnerableLogin(username, password string) bool {
	// VULNERABLE: Direct string concatenation
	query := fmt.Sprintf("SELECT * FROM users WHERE username = '%s' AND password = '%s'", username, password)

	fmt.Printf("Executing query: %s\n", query)

	rows, err := v.db.Query(query)
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		return false
	}
	defer rows.Close()

	return rows.Next()
}

/**
 * VULNERABLE: SQL Injection in search functionality
 */
func (v *VulnerableGo) VulnerableSearch(searchTerm string) {
	// VULNERABLE: Unescaped user input in LIKE clause
	query := fmt.Sprintf("SELECT * FROM users WHERE username LIKE '%%%s%%' OR email LIKE '%%%s%%'", searchTerm, searchTerm)

	fmt.Printf("Executing search query: %s\n", query)

	rows, err := v.db.Query(query)
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		return
	}
	defer rows.Close()

	for rows.Next() {
		var username, email string
		rows.Scan(&username, &email)
		fmt.Printf("Found user: %s, Email: %s\n", username, email)
	}
}

/**
 * VULNERABLE: SQL Injection in UPDATE statement
 */
func (v *VulnerableGo) VulnerableUpdatePassword(username, newPassword string) int64 {
	// VULNERABLE: Direct interpolation in UPDATE
	query := fmt.Sprintf("UPDATE users SET password = '%s' WHERE username = '%s'", newPassword, username)

	fmt.Printf("Executing update query: %s\n", query)

	result, err := v.db.Exec(query)
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		return 0
	}

	rowsAffected, _ := result.RowsAffected()
	return rowsAffected
}

/**
 * VULNERABLE: SQL Injection in DELETE statement
 */
func (v *VulnerableGo) VulnerableDeleteUser(userId string) int64 {
	// VULNERABLE: Direct interpolation in DELETE
	query := fmt.Sprintf("DELETE FROM users WHERE id = %s", userId)

	fmt.Printf("Executing delete query: %s\n", query)

	result, err := v.db.Exec(query)
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		return 0
	}

	rowsAffected, _ := result.RowsAffected()
	return rowsAffected
}

/**
 * VULNERABLE: SQL Injection with Exec (no parameters)
 */
func (v *VulnerableGo) VulnerableExecRaw(query string) error {
	// VULNERABLE: Direct execution of user input
	fmt.Printf("Executing raw query: %s\n", query)

	_, err := v.db.Exec(query)
	return err
}

func main() {
	fmt.Println("Go SQL Injection Vulnerable Code")
	fmt.Println("================================")

	vuln, err := NewVulnerableGo()
	if err != nil {
		fmt.Printf("Failed to connect: %v\n", err)
		return
	}
	defer vuln.db.Close()

	// Test vulnerable login
	testUser := "admin' OR '1'='1'--"
	testPass := "anything"
	loginResult := vuln.VulnerableLogin(testUser, testPass)
	fmt.Printf("Login result: %t\n", loginResult)

	// Test vulnerable search
	searchTerm := "test'; DROP TABLE users;--"
	vuln.VulnerableSearch(searchTerm)

	// Test vulnerable update
	username := "admin"
	newPassword := "hacked'; DROP TABLE users;--"
	updateResult := vuln.VulnerableUpdatePassword(username, newPassword)
	fmt.Printf("Update affected rows: %d\n", updateResult)

	// Test vulnerable delete
	userId := "1 OR 1=1"
	deleteResult := vuln.VulnerableDeleteUser(userId)
	fmt.Printf("Delete affected rows: %d\n", deleteResult)

	// Test raw execution
	rawQuery := "SELECT * FROM users; DROP TABLE users;--"
	err = vuln.VulnerableExecRaw(rawQuery)
	if err != nil {
		fmt.Printf("Raw execution error: %v\n", err)
	}
}