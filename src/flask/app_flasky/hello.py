from flask import Flask
from app_flasky.config import configuration

app = Flask(__name__)
app.config.from_object(configuration)

@app.route('/')
def index():
    return '<h1>Hello World!</h1>'

@app.route('/user/<name>')
def hello(name):
    return '<h1>Hello, %s!</h1>' % name


if __name__ == '__main__':
    import sys
    print(sys.path)
    app.run(host=app.config.get("HOST"),
            port=app.config.get("PORT"),
            threaded=True
    )
