
import random
from tkinter.messagebox import RETRY
from flask import Flask, render_template, render_template_string, request, redirect,flash,session
from flaskext.mysql import MySQL
import yaml
app = Flask(__name__)
app.secret_key = 'random string'
#Configure db
with open('db.yaml', 'r') as file:
    db = yaml.safe_load(file)

# app.config['MYSQL_HOST'] = db['mysql_host']
# app.config['MYSQL_USER'] = db['mysql_user']
# app.config['MYSQL_PASSWORD'] = db['mysql_password']
# app.config['MYSQL_DB'] = db['mysql_db']

temp1 = ''
mysql =MySQL(app, prefix="mysql", host="localhost", user="root", password="ak445308", db="irctc")
mysql.init_app(app)
@app.route('/', methods = ['GET', 'POST'])
def index(): # function returns what to print on screen
    error = None
    if request.method == 'POST':
        userDetails = request.form
        userId = userDetails['userid']
        temp1 = userId
        session['userid'] = userId;
        password = userDetails['password']
        cur = mysql.get_db().cursor()
        result = cur.execute("Select name,password from user where userid = " + userId)
        if(result == 0):
            error = 'Invalid username or password. Please try again!'
        else:
            temp = cur.fetchall()
            cur.close()
            print(temp)
            if(password == temp[0][1]):
                flash("UserID = "+userId)
                return redirect('/book')
            else:
                error = 'Invalid username or password. Please try again!'
    return render_template('index.html', error=error)

@app.route('/register', methods = ['GET', 'POST'])
def register():
    if request.method == 'POST':
        details = request.form
        name = details['name']
        age = details['age']
        userid = details['userid']
        phonenumber = details['phonenumber']
        password = details['password']
        con = mysql.connect()
        cur = con.cursor()
        result = cur.execute("Select * from user where userid = " + userid)
        print(result)
        if result == 0:
            print("inserting")
            cur.execute("insert into user values('" + name + "'," + age + "," + userid + ",'" + phonenumber + "','" + password + "')")
        con.commit()
        cur.close()

    return render_template('register.html')
@app.route('/book', methods = ['GET', 'POST'])
def book():
    if request.method == 'POST':
        trainDetails = request.form
        trainNumber = trainDetails['trainnumber']
        temp1 = session.get('userid',None)
        con = mysql.connect()
        cur = con.cursor()
        temp2 = cur.execute("Select trainno from trains")
        trains = cur.fetchall()
        print(trains)
        flag = 0;
        print("temp1 = "+temp1)

        for i in trains:
            if trainNumber == str(i[0]):
                flag = 1 
        print(flag)
        if flag == 0:
            error = 'Invalid train number'
        else:
            
            result = cur.execute("Select * from user where userid = " + temp1)
            temp = cur.fetchall()
            print(temp)
            cur.execute("Select source,destination,departuredateandtime from trains where trainno = " + trainNumber)
            sd = cur.fetchall()
            print(sd)
            print(type(sd[0][2]))
            date = sd[0][2].strftime("%Y-%m-%d %H:%M:%S")
            cur.execute("select pnr from tickets")
            pnr = cur.fetchall()
            leng = len(pnr)
            fare = random.randrange(100, 1000, 1)
            print("Insert into tickets values (" + str(pnr[leng-1][0] + 1)+","+str(fare)+"," + trainNumber + "," + str(sd[0][0]) + "," + str(sd[0][1]) + ",'"+date+"'")
            cur.execute("Insert into tickets values (" + str(pnr[leng-1][0] + 1)+","+str(fare)+"," + trainNumber + "," + str(sd[0][0]) + "," + str(sd[0][1]) + ",'"+date+"')")
            cur.execute("INSERT INTO passengers VALUES ('" + temp[0][0]+ "','male'," + str(temp[0][1]) + ","+str(pnr[leng-1][0] + 1)+"," + str(temp[0][2])+")")
            ticket = [pnr[leng-1][0] + 1, fare, trainNumber, sd[0][0],sd[0][1],date,temp[0][0],'male',temp[0][1], temp[0][2]]
            con.commit()
            cur.close()
            return render_template('ticket.html', tickets = ticket)   
    return render_template('book.html')

@app.route('/searchtrain', methods = ['GET', 'POST'])
def searchtrain():
    if request.method == 'POST':
        details = request.form
        trainno = details['trainno']
        con = mysql.connect()
        cur = con.cursor()
        temp2 = cur.execute("Select * from trains where trainno = " + trainno)
        trains = cur.fetchall()
        result = cur.execute("Select stationname from stations where stationcode = " + str(trains[0][4]))
        stations = cur.fetchall()
        s = stations[0][0]
        result = cur.execute("Select stationname from stations where stationcode = " + str(trains[0][5]))
        stations = cur.fetchall()
        d = stations[0][0]
        t = [trains[0][0],trains[0][1], trains[0][2].strftime("%Y-%m-%d %H:%M:%S"), s, d]
        return render_template('showtrains.html', trains = t)
    return render_template('usertrainsearc.html')
if __name__ == '__main__':
    app.run(debug=True) #debug=True makes sure whatever changes make gets reflected on the browser without restarting the server.