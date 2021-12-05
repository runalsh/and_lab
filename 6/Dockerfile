FROM python:3.6-alpine as base
FROM base as builder1
RUN mkdir /app
WORKDIR /app
RUN pip install --prefix=/app flask
FROM base as builder2
RUN mkdir /app
WORKDIR /app
RUN wget https://github.com/runalsh/and_lab/archive/refs/heads/lab.zip
RUN unzip ./lab.zip
RUN cp /app/and_lab-lab/2/app.py /app/app.py
RUN rm -rf ./*lab*
FROM base
RUN mkdir /app
COPY --from=builder1 /app /usr/local
COPY --from=builder2 /app/app.py /app
WORKDIR /app
EXPOSE 5000
CMD ["python", "app.py"]
