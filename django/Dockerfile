FROM python:3.6-alpine3.7

# Install build-deps, run the pip install, then remove unneeded build deps in a single layer.
ADD requirements.txt /tmp/requirements.txt
RUN set -ex \
	# && apk add --no-cache --virtual curl \
		# gcc \
		# make \
		# libc-dev \
		# musl-dev \
		# linux-headers \
		# pcre-dev \
		# postgresql-dev \
	&& python3.6 -m venv /venv \
	&& /venv/bin/pip install -U pip \
	&& LIBRARY_PATH=/lib:/usr/lib /bin/sh -c "/venv/bin/pip install --no-cache-dir -r /tmp/requirements.txt" \
  	# && runDeps="$( \
  		# scanelf --needed --nobanner --recursive /venv \
  		# 	| awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
  		# 	| sort -u \
  		# 	| xargs -r apk info --installed \
  		# 	| sort -u \
  	# )" \
  	# && apk add --virtual .python-rundeps $runDeps \
  	# && apk del .build-deps
  	&& echo "install done"

RUN mkdir -p /app/db
WORKDIR /app/
ADD . /app/
VOLUME /app/db

# Set up Django stuff
RUN /venv/bin/python /app/manage.py migrate --noinput
RUN /venv/bin/python /app/manage.py collectstatic --noinput

# Listen on this port
EXPOSE 8000

# Add custom env variables (also read from .env locally)
ENV GUNICORN_CMD_ARGS="--bind=0.0.0.0 --workers=3"

# Do the thing
# CMD ["python3.6","/app/manage.py","runserver","0.0.0.0:8000"]
CMD ["/venv/bin/gunicorn", "superlists.wsgi:application"]
