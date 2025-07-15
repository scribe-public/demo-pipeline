# This file contains intentional security vulnerabilities for testing purposes.

# Vulnerable to SQL Injection
import sqlite3

def insecure_sql_query(user_input):
    conn = sqlite3.connect('example.db')
    cursor = conn.cursor()
    query = f"SELECT * FROM users WHERE username = '{user_input}'"
    cursor.execute(query)
    return cursor.fetchall()

# Hardcoded sensitive information
API_KEY = "12345-ABCDE"

# Command Injection vulnerability
def insecure_command_execution(user_input):
    import os
    os.system(f"echo {user_input}")

# Insecure deserialization
import pickle

def insecure_deserialization(data):
    return pickle.loads(data)

# Weak cryptographic algorithm
import hashlib

def insecure_hashing(password):
    return hashlib.md5(password.encode()).hexdigest()

# Open redirect vulnerability
def insecure_redirect(url):
    from flask import redirect
    return redirect(url)