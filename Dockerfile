FROM tiangolo/uwsgi-nginx-flask:python3.6-alpine3.8

RUN apk --update add bash vim

COPY ./main.py /app
COPY ./requirements.txt /var/www/requirements.txt
RUN pip install -r /var/www/requirements.txt

WORKDIR /app

ENTRYPOINT [ "python3" ]

CMD ["main.py"]

EXPOSE 80