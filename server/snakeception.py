from flask import Flask
from flask import render_template
from reverseproxied import ReverseProxied

app = Flask(__name__)
app.wsgi_app = ReverseProxied(app.wsgi_app)

@app.route('/')
def index():
    return render_template('snake.html')

if __name__ == '__main__':

    app.debug = True
    app.run(port=7002)
