import java.sql.*;

/**
 * Java SQL Injection Vulnerability Example
 *
 * ⚠️ WARNING: This code contains intentional SQL injection vulnerabilities
 * for educational and security research purposes only.
 */
public class JavaVulnerable {

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection("jdbc:sqlite:users.db");
    }

    /**
     * VULNERABLE: SQL Injection through string concatenation
     */
    public static boolean vulnerableLogin(String username, String password) {
        try (Connection conn = getConnection();
             Statement stmt = conn.createStatement()) {

            // VULNERABLE: Direct string concatenation
            String query = "SELECT * FROM users WHERE username = '" + username +
                          "' AND password = '" + password + "'";

            System.out.println("Executing query: " + query);
            ResultSet rs = stmt.executeQuery(query);

            return rs.next();
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * VULNERABLE: SQL Injection in search functionality
     */
    public static void vulnerableSearch(String searchTerm) {
        try (Connection conn = getConnection();
             Statement stmt = conn.createStatement()) {

            // VULNERABLE: Unescaped user input in LIKE clause
            String query = "SELECT * FROM users WHERE username LIKE '%" + searchTerm +
                          "%' OR email LIKE '%" + searchTerm + "%'";

            System.out.println("Executing search query: " + query);
            ResultSet rs = stmt.executeQuery(query);

            while (rs.next()) {
                System.out.println("Found user: " + rs.getString("username"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    /**
     * VULNERABLE: SQL Injection in UPDATE statement
     */
    public static void vulnerableUpdatePassword(String username, String newPassword) {
        try (Connection conn = getConnection();
             Statement stmt = conn.createStatement()) {

            // VULNERABLE: Direct interpolation in UPDATE
            String query = "UPDATE users SET password = '" + newPassword +
                          "' WHERE username = '" + username + "'";

            System.out.println("Executing update query: " + query);
            int rowsAffected = stmt.executeUpdate(query);
            System.out.println("Rows affected: " + rowsAffected);

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    /**
     * VULNERABLE: SQL Injection allowing UNION attacks
     */
    public static void vulnerableGetUserInfo(String userId) {
        try (Connection conn = getConnection();
             Statement stmt = conn.createStatement()) {

            // VULNERABLE: Allows UNION-based injection
            String query = "SELECT username, email FROM users WHERE id = " + userId;

            System.out.println("Executing user info query: " + query);
            ResultSet rs = stmt.executeQuery(query);

            while (rs.next()) {
                System.out.println("User: " + rs.getString("username") +
                                 ", Email: " + rs.getString("email"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public static void main(String[] args) {
        System.out.println("Java SQL Injection Vulnerable Code");
        System.out.println("===================================");

        // Test vulnerable login
        String testUser = "admin' OR '1'='1'--";
        String testPass = "anything";
        boolean loginResult = vulnerableLogin(testUser, testPass);
        System.out.println("Login result: " + loginResult);

        // Test vulnerable search
        String searchTerm = "test'; DROP TABLE users;--";
        vulnerableSearch(searchTerm);

        // Test vulnerable update
        String username = "admin";
        String newPassword = "hacked'; DROP TABLE users;--";
        vulnerableUpdatePassword(username, newPassword);

        // Test UNION injection
        String userId = "1 UNION SELECT username, password FROM users--";
        vulnerableGetUserInfo(userId);
    }
}