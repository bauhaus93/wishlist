FROM node:14 as build
LABEL stage=wishlist-build

WORKDIR /build
COPY . .

WORKDIR /build/frontend
RUN npm install
RUN npm run build
WORKDIR /build

FROM nginx

EXPOSE 80
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
ln -sf /dev/stderr /var/log/nginx/error.log

COPY ./mime.types ./nginx.conf /etc/nginx/
COPY --from=build /build/frontend/public /var/www
