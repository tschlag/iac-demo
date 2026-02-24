import os
import sqlite3
from flask import Flask, request

app = Flask(__name__)

@app.route("/vulnerable-research")
def search():
    # HIGH SEVERITY: SQL Injection
    # Using string formatting instead of parameterized queries allows attackers 
    # to manipulate the database logic.
    user_id = request.args.get("id")
    query = f"SELECT * FROM users WHERE id = '{user_id}'"
    
    conn = sqlite3.connect('database.db')
    cursor = conn.cursor()
    cursor.execute(query) # SAST Trigger: sql_injection
    
    # CRITICAL SEVERITY: Command Injection
    # Passing raw user input into os.system() allows for arbitrary code execution.
    filename = request.args.get("filename")
    os.system(f"cat {filename}") # SAST Trigger: subprocess_shell_injection
    
    return "Analysis complete."

if __name__ == "__main__":
    app.run()