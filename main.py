import os
import sqlite3
from flask import Flask, request

app = Flask(__name__)

@app.route("/vulnerable-research")
def search():
    user_id = request.args.get("id")
    query = f"SELECT * FROM users WHERE id = '{user_id}'"
    
    conn = sqlite3.connect('database.db')
    cursor = conn.cursor()
    cursor.execute(query)
    
    filename = request.args.get("filename")
    os.system(f"cat {filename}") 
    
    return "Analysis complete."

if __name__ == "__main__":
    app.run()