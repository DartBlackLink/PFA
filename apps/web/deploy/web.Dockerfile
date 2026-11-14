ARG NGINX_IMAGE
FROM ${NGINX_IMAGE}
COPY deploy/nginx.conf /etc/nginx/nginx.conf
COPY build/web-final/ /usr/share/nginx/html/
RUN cd /usr/share/nginx/html && \
    version=$(sha256sum main.dart.js | cut -d ' ' -f 1) && \
    mv main.dart.js "main.$version.dart.js" && \
    sed -i "s/main.dart.js/main.$version.dart.js/g" index.html flutter_bootstrap.js
USER nginx
EXPOSE 8080
ENTRYPOINT ["nginx"]
CMD ["-g", "daemon off;"]
