--
-- Lua SQL Injection Vulnerability Example
--
-- ⚠️ WARNING: This code contains intentional SQL injection vulnerabilities
-- for educational and security research purposes only.
--

local lsqlite3 = require("lsqlite3")

-- VULNERABLE: SQL Injection through string concatenation
function vulnerable_login(username, password)
    -- VULNERABLE: Direct string concatenation
    local query = string.format("SELECT * FROM users WHERE username = '%s' AND password = '%s'",
                               username, password)

    print("Executing query: " .. query)

    local db = sqlite3.open("users.db")
    local stmt = db:prepare(query)

    if stmt then
        local result = stmt:step() == sqlite3.ROW
        stmt:finalize()
        db:close()
        return result
    end

    db:close()
    return false
end

-- VULNERABLE: SQL Injection in search functionality
function vulnerable_search(search_term)
    -- VULNERABLE: Unescaped user input in LIKE clause
    local query = string.format("SELECT * FROM users WHERE username LIKE '%%%s%%' OR email LIKE '%%%s%%'",
                               search_term, search_term)

    print("Executing search query: " .. query)

    local db = sqlite3.open("users.db")
    local stmt = db:prepare(query)

    if stmt then
        while stmt:step() == sqlite3.ROW do
            local username = stmt:get_value(1)
            local email = stmt:get_value(2)
            print("Found user: " .. username .. ", Email: " .. email)
        end
        stmt:finalize()
    end

    db:close()
end

-- VULNERABLE: SQL Injection in INSERT statement
function vulnerable_create_user(username, email, password)
    -- VULNERABLE: Direct interpolation in INSERT
    local query = string.format("INSERT INTO users (username, email, password) VALUES ('%s', '%s', '%s')",
                               username, email, password)

    print("Executing insert query: " .. query)

    local db = sqlite3.open("users.db")
    local stmt = db:prepare(query)

    if stmt then
        if stmt:step() == sqlite3.DONE then
            local last_id = db:last_insert_rowid()
            stmt:finalize()
            db:close()
            return last_id
        end
        stmt:finalize()
    end

    db:close()
    return -1
end

-- VULNERABLE: SQL Injection in DELETE statement
function vulnerable_delete_user(user_id)
    -- VULNERABLE: Direct interpolation in DELETE
    local query = string.format("DELETE FROM users WHERE id = %s", user_id)

    print("Executing delete query: " .. query)

    local db = sqlite3.open("users.db")
    local stmt = db:prepare(query)

    if stmt then
        if stmt:step() == sqlite3.DONE then
            local changes = db:changes()
            stmt:finalize()
            db:close()
            return changes
        end
        stmt:finalize()
    end

    db:close()
    return 0
end

-- VULNERABLE: SQL Injection with exec
function vulnerable_exec_raw(sql_input)
    -- VULNERABLE: Direct execution of user input
    print("Executing raw SQL: " .. sql_input)

    local db = sqlite3.open("users.db")
    local result = db:exec(sql_input)
    db:close()

    return result == sqlite3.OK
end

-- Example usage demonstrating vulnerabilities
function demonstrate_vulnerabilities()
    print("Lua SQL Injection Vulnerable Code")
    print("=================================")

    -- Test vulnerable login
    local test_user = "admin' OR '1'='1'--"
    local test_pass = "anything"
    local login_result = vulnerable_login(test_user, test_pass)
    print("Login result: " .. tostring(login_result))

    -- Test vulnerable search
    local search_term = "test'; DROP TABLE users;--"
    vulnerable_search(search_term)

    -- Test vulnerable create
    local username = "newuser"
    local email = "test@example.com"
    local password = "password123"
    local create_result = vulnerable_create_user(username, email, password)
    print("Create result ID: " .. create_result)

    -- Test vulnerable delete
    local user_id = "1 OR 1=1"
    local delete_result = vulnerable_delete_user(user_id)
    print("Delete affected rows: " .. delete_result)

    -- Test raw execution
    local raw_sql = "SELECT * FROM users; DROP TABLE users;--"
    local raw_result = vulnerable_exec_raw(raw_sql)
    print("Raw execution result: " .. tostring(raw_result))
end

-- Run demonstration if this file is executed directly
if arg and arg[0]:find("lua_vulnerable") then
    demonstrate_vulnerabilities()
end