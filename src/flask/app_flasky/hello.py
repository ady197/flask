from flask import Flask
from flask import render_template
from flask_script import Manager
from flask_bootstrap import Bootstrap
from flask_moment import Moment

from datetime import datetime

from app_flasky.config import configuration

app = Flask(__name__)
app.config.from_object(configuration)
bootstrap = Bootstrap(app)
manager = Manager(app)
moment = Moment(app)

@app.route('/')
def index():
    return render_template('index.html',
                            current_time=datetime.utcnow())
    #return render_template('index_with_user.html')
    #return render_template('index.html')

@app.route('/user/<name>')
def hello(name):
    return render_template('user_bootstrap.html',name=name)
    #return render_template('index_with_user.html',user=name)
    #return render_template('user.html',name=name)


if __name__ == '__main__':
    manager.run()
    # app.run(host=app.config.get("HOST"),
    #         port=app.config.get("PORT"),
    #         threaded=True
    # )
