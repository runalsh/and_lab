FROM python:3.6-alpine as base
RUN mkdir /app
WORKDIR /app
RUN pip install --no-cache flask
RUN wget https://github.com/runalsh/and_lab/archive/refs/heads/lab.zip
RUN unzip ./lab.zip
RUN cp /app/and_lab-lab/2/app.py /app/app.py
RUN rm -rf ./*lab*
EXPOSE 5000
CMD ["python", "app.py"]
