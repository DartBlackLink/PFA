ARG NGINX_IMAGE
FROM ${NGINX_IMAGE}
COPY deploy/nginx.conf /etc/nginx/nginx.conf
COPY build/web-final/ /usr/share/nginx/html/
USER nginx
EXPOSE 8080
ENTRYPOINT ["nginx"]
CMD ["-g", "daemon off;"]
