FROM python:3.9-alpine

ARG USER=app

RUN apk update
RUN apk add pkgconfig
RUN apk add --no-cache gcc musl-dev mariadb-connector-c-dev 

RUN mkdir /home/$USER
RUN addgroup -S $USER && adduser -S $USER -G $USER

WORKDIR /home/$USER

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

RUN chown -R $USER:$USER /home/$USER \
    && chmod 777 -R /home/$USER

USER $USER

CMD ["python", "manage.py", "runserver"]
