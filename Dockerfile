# Dockerfile - this is a comment. Delete me if you want.
FROM python:3.7-alpine

COPY . /app

WORKDIR /app

RUN apk --update --upgrade add --no-cache  gcc musl-dev jpeg-dev zlib-dev libffi-dev cairo-dev pango-dev gdk-pixbuf-dev

RUN python -m pip install --upgrade pip
RUN pip install -r requirements.txt
EXPOSE 5000
COPY . .
CMD [ "python", "run.py" ]