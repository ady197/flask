# Dockerfile.python
FROM python:3.7 as python-base
RUN pip install --upgrade pip
ENV WORKDIR /app
WORKDIR ${WORKDIR}
COPY ./requirements.txt ./
RUN pip install -r requirements.txt
ENV PYTHONPATH "${PYTHONPATH}:${WORKDIR}/src/flask:${WORKDIR}/src/python"

FROM python-base as dev
ENV PORT 80
EXPOSE ${PORT}/tcp
ENV FLASK_ENV "development"
CMD exec python "./src/flask/app_flasky/hello.py" runserver --host "0.0.0.0" --port "${PORT}"

# TODO: Use docker image on Heroku and remove from ./bin/{web,release} scripts
# FROM python-base as prod
# ENV PORT 80
# EXPOSE ${PORT}/tcp
# ENV FLASK_ENV "production"
# COPY ./src/flask ./src/flask
# COPY ./src/python ./src/python
# CMD exec python "./src/flask/app_flasky/app.py" runserver --host "0.0.0.0" --port "${PORT}"
