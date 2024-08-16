FROM docker.io/perl:5.40

# Move it
WORKDIR /opt
COPY lib/ ./lib/
COPY migrations/ ./migrations/
COPY public/ ./public/
COPY t/ ./t/
COPY templates/ ./templates/
COPY script/ ./script/
COPY cpanfile .
COPY post_text.conf .

# Dependency time
RUN apt-get update
RUN apt-get -y upgrade
RUN cpanm --installdeps .

# Finish setting up the environment
ENV MOJO_REVERSE_PROXY=1
EXPOSE 3000

# Send it
CMD ["perl", "script/post_text", "prefork", "-m", "production"]
