FROM python:2.7

RUN apt-get install

WORKDIR /app
RUN mkdir /app/static/
COPY app.py /app/
COPY runtop.sh /app/
COPY requirements.txt /app/

RUN pip install -r requirements.txt

EXPOSE 5000

ENTRYPOINT ["python", "app.py"]
