FROM python:3.7
ADD . /code
WORKDIR /code
RUN pip3 install -r _misc/requirements.txt 
RUN echo "Hello world" 
RUN bash init_hotspot.sh
CMD python __init__.py
