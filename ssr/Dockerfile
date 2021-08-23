FROM selenium/standalone-chrome

COPY . .


USER root
RUN mkdir -p /var/ssr && chown seluser /var/ssr
RUN apt-get update && apt-get install python3-distutils python3-venv -y
RUN wget https://bootstrap.pypa.io/get-pip.py
RUN python3 get-pip.py
USER seluser
RUN python3 -m pip install -r requirements.txt

CMD ["python3", "main.py"]

