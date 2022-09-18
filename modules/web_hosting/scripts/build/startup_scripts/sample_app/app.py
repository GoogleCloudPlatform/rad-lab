import os
from flask import Flask, render_template, request, url_for, flash, redirect
import sqlalchemy
from google.cloud.sql.connector import Connector, IPTypes

# initialize connector
connector = Connector()

db_conn_name = os.environ.get('INSTANCE_CONNECTION_NAME')
db_user = os.environ.get('CLOUD_SQL_USERNAME')
db_pass = os.environ.get('CLOUD_SQL_PASSWORD')
db_name = os.environ.get('CLOUD_SQL_DATABASE_NAME')
# db_host = "127.0.0.1"
# db_port = "5432"

app = Flask(__name__)

@app.route('/')
def index():
    accounts = []
    accounts = get_db_accounts(accounts)  
    return render_template('index.html', accounts=accounts)


@app.route('/create', methods=('GET', 'POST'))
def create():
    accounts = []
    if request.method == 'POST':
        name = request.form['name']
        email = request.form['email']

        if not name:
            flash('Name is required!')
        elif not email:
            flash('Email is required!')
        else:
            # Insert record in DB
            create_db_accounts(name, email)
            return redirect(url_for('index'))

    return render_template('create.html')


# connect_tcp_socket initializes a TCP connection pool
# for a Cloud SQL instance of Postgres.
# def connect_tcp_socket() -> sqlalchemy.engine.base.Engine:

#     pool = sqlalchemy.create_engine(
#         # Equivalent URL:
#         # postgresql+pg8000://<db_user>:<db_pass>@<db_host>:<db_port>/<db_name>
#         sqlalchemy.engine.url.URL.create(
#             drivername="postgresql+pg8000",
#             username=db_user,
#             password=db_pass,
#             host=db_host,
#             port=db_port,
#             database=db_name,
#         ),
#     )
#     return pool

# getconn now set to private IP
def getconn():
    # initialize connector
    
    conn = connector.connect(
      db_conn_name,
      "pg8000",
      user=db_user,
      password=db_pass,
      db=db_name,
      ip_type=IPTypes.PRIVATE
    )
    return conn


def get_db_accounts(accounts):
    # pool = connect_tcp_socket()
    pool = sqlalchemy.create_engine("postgresql+pg8000://",creator=getconn,)
    with pool.connect() as db_conn:
        # query database
        result = db_conn.execute("SELECT * from accounts").fetchall()
    
    # cleanup connector
    connector.close()

    # Do something with the results
    for row in result:
        accounts.append({'name': row.name,'email': row.email})
    
    return accounts

def create_db_accounts(name, email):
    # pool = connect_tcp_socket()
    pool = sqlalchemy.create_engine("postgresql+pg8000://",creator=getconn,)

    # insert statement
    insert_stmt = sqlalchemy.text(
        "INSERT INTO accounts (name, email) VALUES (:name, :email)",
    )
    with pool.connect() as db_conn:
        # query database
        db_conn.execute(insert_stmt, name=name, email=email)
    
    # cleanup connector
    connector.close()
    

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=80)
    # app.run(debug=True)