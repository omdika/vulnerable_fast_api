<#
PowerShell SQL Injection Vulnerability Example

⚠️ WARNING: This code contains intentional SQL injection vulnerabilities
for educational and security research purposes only.
#>

Add-Type -Path "System.Data.SQLite.dll"

# VULNERABLE: SQL Injection through string concatenation
function Vulnerable-Login {
    param(
        [string]$Username,
        [string]$Password
    )

    # VULNERABLE: Direct string concatenation
    $query = "SELECT * FROM users WHERE username = '$Username' AND password = '$Password'"

    Write-Host "Executing query: $query"

    $connection = New-Object System.Data.SQLite.SQLiteConnection
    $connection.ConnectionString = "Data Source=users.db"
    $connection.Open()

    $command = $connection.CreateCommand()
    $command.CommandText = $query

    $reader = $command.ExecuteReader()
    $result = $reader.HasRows

    $reader.Close()
    $connection.Close()

    return $result
}

# VULNERABLE: SQL Injection in search functionality
function Vulnerable-Search {
    param([string]$SearchTerm)

    # VULNERABLE: Unescaped user input in LIKE clause
    $query = "SELECT * FROM users WHERE username LIKE '%$SearchTerm%' OR email LIKE '%$SearchTerm%'"

    Write-Host "Executing search query: $query"

    $connection = New-Object System.Data.SQLite.SQLiteConnection
    $connection.ConnectionString = "Data Source=users.db"
    $connection.Open()

    $command = $connection.CreateCommand()
    $command.CommandText = $query

    $reader = $command.ExecuteReader()

    while ($reader.Read()) {
        $username = $reader["username"]
        $email = $reader["email"]
        Write-Host "Found user: $username, Email: $email"
    }

    $reader.Close()
    $connection.Close()
}

# VULNERABLE: SQL Injection in INSERT statement
function Vulnerable-CreateUser {
    param(
        [string]$Username,
        [string]$Email,
        [string]$Password
    )

    # VULNERABLE: Direct interpolation in INSERT
    $query = "INSERT INTO users (username, email, password) VALUES ('$Username', '$Email', '$Password')"

    Write-Host "Executing insert query: $query"

    $connection = New-Object System.Data.SQLite.SQLiteConnection
    $connection.ConnectionString = "Data Source=users.db"
    $connection.Open()

    $command = $connection.CreateCommand()
    $command.CommandText = $query

    $rowsAffected = $command.ExecuteNonQuery()

    $connection.Close()

    return $rowsAffected
}

# VULNERABLE: SQL Injection in DELETE statement
function Vulnerable-DeleteUser {
    param([string]$UserId)

    # VULNERABLE: Direct interpolation in DELETE
    $query = "DELETE FROM users WHERE id = $UserId"

    Write-Host "Executing delete query: $query"

    $connection = New-Object System.Data.SQLite.SQLiteConnection
    $connection.ConnectionString = "Data Source=users.db"
    $connection.Open()

    $command = $connection.CreateCommand()
    $command.CommandText = $query

    $rowsAffected = $command.ExecuteNonQuery()

    $connection.Close()

    return $rowsAffected
}

# VULNERABLE: SQL Injection with ExecuteNonQuery
function Vulnerable-ExecRaw {
    param([string]$SqlInput)

    # VULNERABLE: Direct execution of user input
    Write-Host "Executing raw SQL: $SqlInput"

    $connection = New-Object System.Data.SQLite.SQLiteConnection
    $connection.ConnectionString = "Data Source=users.db"
    $connection.Open()

    $command = $connection.CreateCommand()
    $command.CommandText = $SqlInput

    $rowsAffected = $command.ExecuteNonQuery()

    $connection.Close()

    return $rowsAffected
}

# Example usage demonstrating vulnerabilities
function Demonstrate-Vulnerabilities {
    Write-Host "PowerShell SQL Injection Vulnerable Code"
    Write-Host "========================================"

    # Test vulnerable login
    $testUser = "admin' OR '1'='1'--"
    $testPass = "anything"
    $loginResult = Vulnerable-Login -Username $testUser -Password $testPass
    Write-Host "Login result: $loginResult"

    # Test vulnerable search
    $searchTerm = "test'; DROP TABLE users;--"
    Vulnerable-Search -SearchTerm $searchTerm

    # Test vulnerable create
    $username = "newuser"
    $email = "test@example.com"
    $password = "password123"
    $createResult = Vulnerable-CreateUser -Username $username -Email $email -Password $password
    Write-Host "Create affected rows: $createResult"

    # Test vulnerable delete
    $userId = "1 OR 1=1"
    $deleteResult = Vulnerable-DeleteUser -UserId $userId
    Write-Host "Delete affected rows: $deleteResult"

    # Test raw execution
    $rawSql = "SELECT * FROM users; DROP TABLE users;--"
    $rawResult = Vulnerable-ExecRaw -SqlInput $rawSql
    Write-Host "Raw execution affected rows: $rawResult"
}

# Run demonstration if this script is executed directly
if ($MyInvocation.InvocationName -eq ".\powershell_vulnerable.ps1") {
    Demonstrate-Vulnerabilities
}