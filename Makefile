PROJECT_NAME = wishlist
BACKEND_DIR = $(PWD)/backend
FRONTEND_DIR = $(PWD)/frontend
WWW_DIR = $(FRONTEND_DIR)/www
NGINX_DIR = $(PWD)/nginx
LOG_DIR = $(PWD)/logs

CONTAINER_BACKEND_LOG_DIR = /app/log
CONTAINER_FRONTEND_LOG_DIR = /var/log/nginx
CONTAINER_LETSENCRYPT_DIR = /etc/letsencrypt
VOLUME_LETSENCRYPT = wishlist_letsencrypt_volume
TMP_CONTAINER = container-tmp

.PHONY: backend_base backend frontend_base frontend frontend_volumes rebuild build cleanup service stop status logs logs_nginx_access logs_nginx_error logs_backend tags cert

rebuild: backend_base backend frontend_base frontend

build: backend frontend

backend:
	docker build -t schlemihl/$(PROJECT_NAME)-backend -f $(PWD)/docker/backend/Dockerfile $(BACKEND_DIR)

backend_base:
	docker build -t $(PROJECT_NAME)-backend-base -f $(PWD)/docker/backend/Dockerfile-Base $(BACKEND_DIR)

publish: backend
	docker push schlemihl/wishlist-backend:latest

frontend: frontend_volumes
	npm --prefix $(FRONTEND_DIR) run build

frontend_base:
	npm --prefix $(FRONTEND_DIR) install

frontend_volumes:
	docker container create --name $(TMP_CONTAINER) -v $(PROJECT_NAME)_frontend_nginx_conf:/etc/nginx -v $(PROJECT_NAME)_frontend_public:/var/www alpine && \
	docker cp $(NGINX_DIR)/nginx.conf $(TMP_CONTAINER):/etc/nginx/nginx.conf && \
	docker cp $(NGINX_DIR)/mime.types $(TMP_CONTAINER):/etc/nginx/mime.types && \
	docker cp $(WWW_DIR) $(TMP_CONTAINER):/var; \
	docker rm $(TMP_CONTAINER)

service:
	docker-compose --env-file .env -p $(PROJECT_NAME) up -d

stop:
	docker-compose -p $(PROJECT_NAME) down

status:
	docker-compose -p $(PROJECT_NAME) ps

logs:
	rm -rf $(LOG_DIR) && \
	mkdir -p $(LOG_DIR) && \
	docker container create --name $(TMP_CONTAINER) -v $(PROJECT_NAME)_log_nginx:$(CONTAINER_FRONTEND_LOG_DIR) -v $(PROJECT_NAME)_log_backend:$(CONTAINER_BACKEND_LOG_DIR) alpine && \
	docker cp $(TMP_CONTAINER):$(CONTAINER_BACKEND_LOG_DIR) $(LOG_DIR) && \
	docker cp $(TMP_CONTAINER):$(CONTAINER_FRONTEND_LOG_DIR) $(LOG_DIR); \
	docker rm $(TMP_CONTAINER)

cert_new: stop
	docker volume create --name "$(VOLUME_LETSENCRYPT)" && \
	docker run -it --rm -p "80:80" -v "$(VOLUME_LETSENCRYPT):/etc/letsencrypt" certbot/certbot certonly --standalone --preferred-challenges http -d winglers-liste.info -d www.winglers-liste.info

cert_renew: stop
	docker run -it --rm -p "80:80" -v "$(VOLUME_LETSENCRYPT):/etc/letsencrypt" certbot/certbot renew --quiet

logs_nginx_access: logs
	cat $(LOG_DIR)/nginx/$(PROJECT_NAME)-access.log

logs_nginx_error: logs
	cat $(LOG_DIR)/nginx/$(PROJECT_NAME)-error.log

logs_backend: logs
	cat $(LOG_DIR)/log/output.log

clean:
	docker image prune -f --filter label=stage=wishlist-build; \
	rm -rf $(LOG_DIR) tags;

attach_frontend:
	docker exec -i -t $(PROJECT_NAME)_frontend_1 sh

tags:
	ctags -R backend/src
