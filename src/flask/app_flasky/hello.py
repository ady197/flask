from flask import Flask
from flask_script import Manager
from app_flasky.config import configuration

app = Flask(__name__)
app.config.from_object(configuration)
manager = Manager(app)

@app.route('/')
def index():
    return '<h1>Hello World!</h1>'

@app.route('/user/<name>')
def hello(name):
    return '<h1>Hello, %s!</h1>' % name


if __name__ == '__main__':
    manager.run()
    # app.run(host=app.config.get("HOST"),
    #         port=app.config.get("PORT"),
    #         threaded=True
    # )
