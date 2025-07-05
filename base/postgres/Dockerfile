FROM postgres:17.2

ENV POSTGRES_DB=mspr502
ENV POSTGRES_USER=mspr502
ENV POSTGRES_PASSWORD=s5t4v5

COPY ./database/initdb.sql /docker-entrypoint-initdb.d/

EXPOSE 5432
