from os import getenv


def get_value(key):
    if not getenv(key):
        raise Exception("Empty {0} configuration value".format(key))
    return getenv(key)


class Configuration(object):
    DEBUG = False
    TESTING = False

    DATABASE_URL = get_value("DATABASE_URL")
    SECRET_KEY = get_value("SECRET_KEY")
    SQLALCHEMY_COMMIT_ON_TEARDOWN = True
    SQLALCHEMY_DATABASE_URI = get_value("DATABASE_URL")
    SQLALCHEMY_TRACK_MODIFICATIONS = False

    PORT = getenv("PORT") if getenv("PORT") else "80"
    HOST = getenv("HOST") if getenv("HOST") else "0.0.0.0"


class Development(Configuration):
    DEBUG = True
    SQLALCHEMY_TRACK_MODIFICATIONS = True


configuration = Development if getenv(
    "FLASK_ENV") == "development" else Configuration
