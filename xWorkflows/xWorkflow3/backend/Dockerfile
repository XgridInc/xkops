FROM python:3.12
WORKDIR /apps
COPY requirements.txt . 
RUN pip install --no-cache-dir -r requirements.txt
RUN pip show pymongo
COPY . .
CMD ["python", "app.py"]