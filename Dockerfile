FROM tiangolo/uwsgi-nginx-flask:python3.6-alpine3.8

RUN apk --update add bash vim

COPY ./main.py /app

WORKDIR /app

ENTRYPOINT [ "python3" ]

CMD ["main.py"]

EXPOSE 80