from flask import Flask, request, jsonify
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
from utils import mirror_word
import psycopg2
import os

app = Flask(__name__)

# Initialize Key Vault client
key_vault_url = "https://swiss-kv-01.vault.azure.net/"
credential = DefaultAzureCredential()
client = SecretClient(vault_url=key_vault_url, credential=credential)

# Fetch secrets from Key Vault
DB_PASS = client.get_secret("postgres-password").value
DB_USER = client.get_secret("postgres-username").value
DB_NAME = client.get_secret("postgres-dbname").value
DB_HOST = "swiss-postgres-01.postgres.database.azure.com"

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

#def mirror_word(word):
#    flipped = ''.join(
#        c.lower() if c.isupper() else c.upper() if c.islower() else c
#        for c in word
#    )[::-1]
#    return flipped

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
    app.run(host="0.0.0.0", port=4004)