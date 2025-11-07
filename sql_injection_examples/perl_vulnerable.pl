#!/usr/bin/perl

# Perl SQL Injection Vulnerability Example
#
# ⚠️ WARNING: This code contains intentional SQL injection vulnerabilities
# for educational and security research purposes only.

use strict;
use warnings;
use DBI;

package VulnerablePerl;

sub new {
    my $class = shift;
    my $self = {};

    $self->{dbh} = DBI->connect("dbi:SQLite:dbname=users.db", "", "", {
        RaiseError => 1,
        AutoCommit => 1
    }) or die "Cannot connect: $DBI::errstr";

    bless $self, $class;
    return $self;
}

# VULNERABLE: SQL Injection through string concatenation
sub vulnerable_login {
    my ($self, $username, $password) = @_;

    # VULNERABLE: Direct string concatenation
    my $query = "SELECT * FROM users WHERE username = '$username' AND password = '$password'";

    print "Executing query: $query\n";

    my $sth = $self->{dbh}->prepare($query);
    $sth->execute();

    my $user = $sth->fetchrow_hashref();
    return $user;
}

# VULNERABLE: SQL Injection in search functionality
sub vulnerable_search {
    my ($self, $search_term) = @_;

    # VULNERABLE: Unescaped user input in LIKE clause
    my $query = "SELECT * FROM users WHERE username LIKE '%$search_term%' OR email LIKE '%$search_term%'";

    print "Executing search query: $query\n";

    my $sth = $self->{dbh}->prepare($query);
    $sth->execute();

    my @results;
    while (my $row = $sth->fetchrow_hashref()) {
        push @results, $row;
    }
    return \@results;
}

# VULNERABLE: SQL Injection in INSERT statement
sub vulnerable_create_user {
    my ($self, $username, $email, $password) = @_;

    # VULNERABLE: Direct interpolation in INSERT
    my $query = "INSERT INTO users (username, email, password) VALUES ('$username', '$email', '$password')";

    print "Executing insert query: $query\n";

    my $sth = $self->{dbh}->prepare($query);
    $sth->execute();

    return $self->{dbh}->last_insert_id("", "", "", "");
}

# VULNERABLE: SQL Injection in DELETE statement
sub vulnerable_delete_user {
    my ($self, $user_id) = @_;

    # VULNERABLE: Direct interpolation in DELETE
    my $query = "DELETE FROM users WHERE id = $user_id";

    print "Executing delete query: $query\n";

    my $sth = $self->{dbh}->prepare($query);
    $sth->execute();

    return $sth->rows;
}

# VULNERABLE: SQL Injection with do() method
sub vulnerable_do_raw {
    my ($self, $sql_input) = @_;

    # VULNERABLE: Direct execution of user input
    print "Executing raw SQL: $sql_input\n";

    my $rows_affected = $self->{dbh}->do($sql_input);
    return $rows_affected;
}

sub DESTROY {
    my $self = shift;
    $self->{dbh}->disconnect() if $self->{dbh};
}

package main;

# Example usage demonstrating vulnerabilities
sub demonstrate_vulnerabilities {
    print "Perl SQL Injection Vulnerable Code\n";
    print "==================================\n";

    my $vuln = VulnerablePerl->new();

    # Test vulnerable login
    my $test_user = "admin' OR '1'='1'--";
    my $test_pass = "anything";
    my $login_result = $vuln->vulnerable_login($test_user, $test_pass);
    print "Login result: " . ($login_result ? "Success\n" : "Failed\n");

    # Test vulnerable search
    my $search_term = "test'; DROP TABLE users;--";
    my $search_results = $vuln->vulnerable_search($search_term);
    print "Search results count: " . scalar(@$search_results) . "\n";

    # Test vulnerable create
    my $username = "newuser";
    my $email = "test\@example.com";
    my $password = "password123";
    my $create_result = $vuln->vulnerable_create_user($username, $email, $password);
    print "Create result ID: $create_result\n";

    # Test vulnerable delete
    my $user_id = "1 OR 1=1";
    my $delete_result = $vuln->vulnerable_delete_user($user_id);
    print "Delete affected rows: $delete_result\n";

    # Test raw execution
    my $raw_sql = "SELECT * FROM users; DROP TABLE users;--";
    my $raw_result = $vuln->vulnerable_do_raw($raw_sql);
    print "Raw execution affected rows: $raw_result\n";
}

# Run demonstration if this file is executed directly
demonstrate_vulnerabilities() unless caller();

1;