from flask import Flask, request, jsonify
import psycopg2
import os

app = Flask(__name__)

# Database connection settings (replace with your Azure PostgreSQL credentials)
DB_HOST = os.getenv("DB_HOST", "your-db-name.postgres.database.azure.com")
DB_NAME = os.getenv("DB_NAME", "yourdbname")
DB_USER = os.getenv("DB_USER", "yourusername@your-db-name")
DB_PASS = os.getenv("DB_PASS", "yourpassword")

# Connect to PostgreSQL
conn = psycopg2.connect(
    host=DB_HOST,
    dbname=DB_NAME,
    user=DB_USER,
    password=DB_PASS,
    sslmode='require'
)
cursor = conn.cursor()
cursor.execute("""
    CREATE TABLE IF NOT EXISTS mirrors (
        id SERIAL PRIMARY KEY,
        original TEXT NOT NULL,
        transformed TEXT NOT NULL
    )
""")
conn.commit()

@app.route('/api/health')
def health():
    return jsonify(status="ok")

def mirror_word(word):
    flipped = ''.join(
        c.lower() if c.isupper() else c.upper() if c.islower() else c
        for c in word
    )[::-1]
    return flipped

@app.route('/api/mirror')
def mirror():
    word = request.args.get('word', '')
    if not word:
        return jsonify(error="Missing 'word' parameter"), 400
    transformed = mirror_word(word)
    cursor.execute("INSERT INTO mirrors (original, transformed) VALUES (%s, %s)", (word, transformed))
    conn.commit()
    return jsonify(transformed=transformed)

if __name__ == '__main__':
    app.run(port=4004)