# BAD CODE: This is vulnerable to command injection and would fail semgrep security checks
import os

user_input = input("Enter a shell command: ")
os.system(user_input)

# BAD CODE: SQL Injection vulnerability example
import sqlite3

conn = sqlite3.connect(':memory:')
cursor = conn.cursor()
cursor.execute('CREATE TABLE users (id INTEGER PRIMARY KEY, username TEXT, password TEXT)')

username = input("Enter username: ")
query = f"SELECT * FROM users WHERE username = '{username}'"
cursor.execute(query)
print(cursor.fetchall())


secret="ghp_abCDefGHijKLmnOPqrSTuvWXyz1234567890"

