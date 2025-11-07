<?php
/**
 * PHP SQL Injection Vulnerability Example
 *
 * ⚠️ WARNING: This code contains intentional SQL injection vulnerabilities
 * for educational and security research purposes only.
 */

class VulnerablePHP {
    private $connection;

    public function __construct() {
        $this->connection = new mysqli('localhost', 'username', 'password', 'users_db');
        if ($this->connection->connect_error) {
            die("Connection failed: " . $this->connection->connect_error);
        }
    }

    /**
     * VULNERABLE: SQL Injection through string concatenation
     */
    public function vulnerableLogin($username, $password) {
        // VULNERABLE: Direct string concatenation
        $query = "SELECT * FROM users WHERE username = '$username' AND password = '$password'";

        echo "Executing query: $query\n";

        $result = $this->connection->query($query);

        if ($result && $result->num_rows > 0) {
            return $result->fetch_assoc();
        }
        return null;
    }

    /**
     * VULNERABLE: SQL Injection in search functionality
     */
    public function vulnerableSearch($searchTerm) {
        // VULNERABLE: Unescaped user input in LIKE clause
        $query = "SELECT * FROM users WHERE username LIKE '%$searchTerm%' OR email LIKE '%$searchTerm%'";

        echo "Executing search query: $query\n";

        $result = $this->connection->query($query);
        $users = [];

        if ($result) {
            while ($row = $result->fetch_assoc()) {
                $users[] = $row;
            }
        }
        return $users;
    }

    /**
     * VULNERABLE: SQL Injection in UPDATE statement
     */
    public function vulnerableUpdateProfile($userId, $newEmail) {
        // VULNERABLE: Direct interpolation in UPDATE
        $query = "UPDATE users SET email = '$newEmail' WHERE id = $userId";

        echo "Executing update query: $query\n";

        return $this->connection->query($query);
    }

    /**
     * VULNERABLE: SQL Injection in DELETE statement
     */
    public function vulnerableDeleteUser($username) {
        // VULNERABLE: Direct interpolation in DELETE
        $query = "DELETE FROM users WHERE username = '$username'";

        echo "Executing delete query: $query\n";

        return $this->connection->query($query);
    }

    /**
     * VULNERABLE: SQL Injection with multiple statements
     */
    public function vulnerableMultiQuery($input) {
        // VULNERABLE: Allows multiple statements
        $query = "SELECT * FROM users WHERE username = '$input'";

        echo "Executing multi-query: $query\n";

        if ($this->connection->multi_query($query)) {
            $results = [];
            do {
                if ($result = $this->connection->store_result()) {
                    while ($row = $result->fetch_assoc()) {
                        $results[] = $row;
                    }
                    $result->free();
                }
            } while ($this->connection->more_results() && $this->connection->next_result());

            return $results;
        }
        return null;
    }

    public function __destruct() {
        $this->connection->close();
    }
}

// Example usage demonstrating vulnerabilities
function demonstrateVulnerabilities() {
    echo "PHP SQL Injection Vulnerable Code\n";
    echo "==================================\n";

    $vuln = new VulnerablePHP();

    // Test vulnerable login
    $testUser = "admin' OR '1'='1'--";
    $testPass = "anything";
    $loginResult = $vuln->vulnerableLogin($testUser, $testPass);
    echo "Login result: " . ($loginResult ? "Success\n" : "Failed\n");

    // Test vulnerable search
    $searchTerm = "test'; DROP TABLE users;--";
    $searchResults = $vuln->vulnerableSearch($searchTerm);
    echo "Search results count: " . count($searchResults) . "\n";

    // Test vulnerable update
    $userId = "1";
    $newEmail = "hacked@example.com'; DROP TABLE users;--";
    $updateResult = $vuln->vulnerableUpdateProfile($userId, $newEmail);
    echo "Update result: " . ($updateResult ? "Success\n" : "Failed\n");

    // Test vulnerable delete
    $username = "test'; DROP TABLE users;--";
    $deleteResult = $vuln->vulnerableDeleteUser($username);
    echo "Delete result: " . ($deleteResult ? "Success\n" : "Failed\n");

    // Test multi-query injection
    $multiInput = "admin'; DROP TABLE users; SELECT * FROM admin_users;--";
    $multiResults = $vuln->vulnerableMultiQuery($multiInput);
    echo "Multi-query results count: " . ($multiResults ? count($multiResults) : 0) . "\n";
}

// Run demonstration if this file is executed directly
if (basename(__FILE__) == basename($_SERVER['PHP_SELF'])) {
    demonstrateVulnerabilities();
}
?>