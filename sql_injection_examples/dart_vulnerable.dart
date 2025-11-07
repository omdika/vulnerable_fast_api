/*
 * Dart SQL Injection Vulnerability Example
 *
 * ⚠️ WARNING: This code contains intentional SQL injection vulnerabilities
 * for educational and security research purposes only.
 */

import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class VulnerableDart {
  late Database _db;

  Future<void> init() async {
    _db = await openDatabase(
      join(await getDatabasesPath(), 'users.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE users(id INTEGER PRIMARY KEY, username TEXT, email TEXT, password TEXT)',
        );
      },
      version: 1,
    );
  }

  /**
   * VULNERABLE: SQL Injection through string concatenation
   */
  Future<bool> vulnerableLogin(String username, String password) async {
    // VULNERABLE: Direct string concatenation
    String query = "SELECT * FROM users WHERE username = '$username' AND password = '$password'";

    print('Executing query: $query');

    List<Map<String, dynamic>> result = await _db.rawQuery(query);
    return result.isNotEmpty;
  }

  /**
   * VULNERABLE: SQL Injection in search functionality
   */
  Future<void> vulnerableSearch(String searchTerm) async {
    // VULNERABLE: Unescaped user input in LIKE clause
    String query = "SELECT * FROM users WHERE username LIKE '%$searchTerm%' OR email LIKE '%$searchTerm%'";

    print('Executing search query: $query');

    List<Map<String, dynamic>> results = await _db.rawQuery(query);

    for (var row in results) {
      print('Found user: ${row['username']}, Email: ${row['email']}');
    }
  }

  /**
   * VULNERABLE: SQL Injection in INSERT statement
   */
  Future<int> vulnerableCreateUser(String username, String email, String password) async {
    // VULNERABLE: Direct interpolation in INSERT
    String query = "INSERT INTO users (username, email, password) VALUES ('$username', '$email', '$password')";

    print('Executing insert query: $query');

    int result = await _db.rawInsert(query);
    return result;
  }

  /**
   * VULNERABLE: SQL Injection in DELETE statement
   */
  Future<int> vulnerableDeleteUser(String userId) async {
    // VULNERABLE: Direct interpolation in DELETE
    String query = "DELETE FROM users WHERE id = $userId";

    print('Executing delete query: $query');

    int result = await _db.rawDelete(query);
    return result;
  }

  /**
   * VULNERABLE: SQL Injection with execute
   */
  Future<void> vulnerableExecuteRaw(String sqlInput) async {
    // VULNERABLE: Direct execution of user input
    print('Executing raw SQL: $sqlInput');

    await _db.execute(sqlInput);
  }

  Future<void> close() async {
    await _db.close();
  }
}

// Example usage demonstrating vulnerabilities
void demonstrateVulnerabilities() async {
  print('Dart SQL Injection Vulnerable Code');
  print('===================================');

  var vuln = VulnerableDart();
  await vuln.init();

  try {
    // Test vulnerable login
    String testUser = "admin' OR '1'='1'--";
    String testPass = "anything";
    bool loginResult = await vuln.vulnerableLogin(testUser, testPass);
    print('Login result: $loginResult');

    // Test vulnerable search
    String searchTerm = "test'; DROP TABLE users;--";
    await vuln.vulnerableSearch(searchTerm);

    // Test vulnerable create
    String username = "newuser";
    String email = "test@example.com";
    String password = "password123";
    int createResult = await vuln.vulnerableCreateUser(username, email, password);
    print('Create result ID: $createResult');

    // Test vulnerable delete
    String userId = "1 OR 1=1";
    int deleteResult = await vuln.vulnerableDeleteUser(userId);
    print('Delete affected rows: $deleteResult');

    // Test raw execution
    String rawSql = "SELECT * FROM users; DROP TABLE users;--";
    await vuln.vulnerableExecuteRaw(rawSql);
    print('Raw execution completed');

  } finally {
    await vuln.close();
  }
}

// Run demonstration if this file is executed directly
void main() {
  demonstrateVulnerabilities();
}