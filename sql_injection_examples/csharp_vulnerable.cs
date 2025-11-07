using System;
using System.Data.SqlClient;

/**
 * C# SQL Injection Vulnerability Example
 *
 * ⚠️ WARNING: This code contains intentional SQL injection vulnerabilities
 * for educational and security research purposes only.
 */

namespace SqlInjectionExamples
{
    public class VulnerableCSharp
    {
        private string connectionString = "Server=localhost;Database=users_db;Trusted_Connection=true;";

        /**
         * VULNERABLE: SQL Injection through string concatenation
         */
        public bool VulnerableLogin(string username, string password)
        {
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                connection.Open();

                // VULNERABLE: Direct string concatenation
                string query = $"SELECT * FROM users WHERE username = '{username}' AND password = '{password}'";

                Console.WriteLine($"Executing query: {query}");

                using (SqlCommand command = new SqlCommand(query, connection))
                using (SqlDataReader reader = command.ExecuteReader())
                {
                    return reader.HasRows;
                }
            }
        }

        /**
         * VULNERABLE: SQL Injection in search functionality
         */
        public void VulnerableSearch(string searchTerm)
        {
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                connection.Open();

                // VULNERABLE: Unescaped user input in LIKE clause
                string query = $"SELECT * FROM users WHERE username LIKE '%{searchTerm}%' OR email LIKE '%{searchTerm}%'";

                Console.WriteLine($"Executing search query: {query}");

                using (SqlCommand command = new SqlCommand(query, connection))
                using (SqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        Console.WriteLine($"Found user: {reader["username"]}");
                    }
                }
            }
        }

        /**
         * VULNERABLE: SQL Injection in UPDATE statement
         */
        public int VulnerableUpdatePassword(string username, string newPassword)
        {
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                connection.Open();

                // VULNERABLE: Direct interpolation in UPDATE
                string query = $"UPDATE users SET password = '{newPassword}' WHERE username = '{username}'";

                Console.WriteLine($"Executing update query: {query}");

                using (SqlCommand command = new SqlCommand(query, connection))
                {
                    return command.ExecuteNonQuery();
                }
            }
        }

        /**
         * VULNERABLE: SQL Injection in DELETE statement
         */
        public int VulnerableDeleteUser(string userId)
        {
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                connection.Open();

                // VULNERABLE: Direct interpolation in DELETE
                string query = $"DELETE FROM users WHERE id = {userId}";

                Console.WriteLine($"Executing delete query: {query}");

                using (SqlCommand command = new SqlCommand(query, connection))
                {
                    return command.ExecuteNonQuery();
                }
            }
        }

        /**
         * VULNERABLE: SQL Injection with dynamic SQL
         */
        public void VulnerableDynamicQuery(string tableName, string condition)
        {
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                connection.Open();

                // VULNERABLE: Dynamic SQL construction
                string query = $"SELECT * FROM {tableName} WHERE {condition}";

                Console.WriteLine($"Executing dynamic query: {query}");

                using (SqlCommand command = new SqlCommand(query, connection))
                using (SqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        Console.WriteLine($"Row: {reader[0]}");
                    }
                }
            }
        }
    }

    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("C# SQL Injection Vulnerable Code");
            Console.WriteLine("=================================");

            var vuln = new VulnerableCSharp();

            // Test vulnerable login
            string testUser = "admin' OR '1'='1'--";
            string testPass = "anything";
            bool loginResult = vuln.VulnerableLogin(testUser, testPass);
            Console.WriteLine($"Login result: {loginResult}");

            // Test vulnerable search
            string searchTerm = "test'; DROP TABLE users;--";
            vuln.VulnerableSearch(searchTerm);

            // Test vulnerable update
            string username = "admin";
            string newPassword = "hacked'; DROP TABLE users;--";
            int updateResult = vuln.VulnerableUpdatePassword(username, newPassword);
            Console.WriteLine($"Update affected rows: {updateResult}");

            // Test vulnerable delete
            string userId = "1 OR 1=1";
            int deleteResult = vuln.VulnerableDeleteUser(userId);
            Console.WriteLine($"Delete affected rows: {deleteResult}");

            // Test dynamic SQL injection
            string tableName = "users";
            string condition = "1=1; DROP TABLE users;--";
            vuln.VulnerableDynamicQuery(tableName, condition);
        }
    }
}