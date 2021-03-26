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
VOLUME_WWW = wishlist_www_volume
TMP_CONTAINER = container-tmp
LOG_PRODUCER = logs_remote
CMD_ACCESS_LOGS = @cat $(LOG_DIR)/nginx/$(PROJECT_NAME)-access.log

.PHONY: backend_base backend frontend frontend_base nginx_conf nginx_conf_test rebuild build cleanup service stop status logs_remote logs_local logs_nginx_access logs_nginx_error logs_backend tags cert remote

rebuild: backend_base backend frontend_base frontend

build: backend frontend nginx_conf

update: stop pull frontend nginx_conf service

backend:
	docker build -t schlemihl/$(PROJECT_NAME)-backend -f $(PWD)/docker/backend/Dockerfile $(BACKEND_DIR)

backend_base:
	docker build -t $(PROJECT_NAME)-backend-base -f $(PWD)/docker/backend/Dockerfile-Base $(BACKEND_DIR)

publish: backend
	docker push schlemihl/wishlist-backend:latest

frontend: frontend_base
	docker container run -it --rm -v "$(VOLUME_WWW):/var/frontend/www" frontend-www-builder

frontend_base:
	docker image build -t frontend-www-builder $(FRONTEND_DIR)

nginx_conf:
	docker container create --name $(TMP_CONTAINER) -v $(PROJECT_NAME)_frontend_nginx_conf:/etc/nginx alpine && \
	docker cp $(NGINX_DIR)/nginx.conf $(TMP_CONTAINER):/etc/nginx/nginx.conf && \
	docker cp $(NGINX_DIR)/mime.types $(TMP_CONTAINER):/etc/nginx/mime.types; \
	docker rm $(TMP_CONTAINER)

nginx_conf_test:
	docker container create --name $(TMP_CONTAINER) -v $(PROJECT_NAME)_frontend_nginx_conf:/etc/nginx alpine && \
	docker cp $(NGINX_DIR)/nginx-test.conf $(TMP_CONTAINER):/etc/nginx/nginx.conf && \
	docker cp $(NGINX_DIR)/mime.types $(TMP_CONTAINER):/etc/nginx/mime.types; \
	docker rm $(TMP_CONTAINER)

service:
	docker-compose --env-file .env -p $(PROJECT_NAME) up -d

pull:
	docker pull schlemihl/$(PROJECT_NAME)-backend && \
		git pull --ff-only

stop:
	docker-compose -p $(PROJECT_NAME) down

status:
	docker-compose -p $(PROJECT_NAME) ps

logs_local:
	@rm -rf $(LOG_DIR) && \
	mkdir -p $(LOG_DIR) && \
	docker container create --name $(TMP_CONTAINER) -v $(PROJECT_NAME)_log_nginx:$(CONTAINER_FRONTEND_LOG_DIR) -v $(PROJECT_NAME)_log_backend:$(CONTAINER_BACKEND_LOG_DIR) alpine > /dev/null && \
	docker cp $(TMP_CONTAINER):$(CONTAINER_BACKEND_LOG_DIR) $(LOG_DIR) && \
	docker cp $(TMP_CONTAINER):$(CONTAINER_FRONTEND_LOG_DIR) $(LOG_DIR); \
	docker rm $(TMP_CONTAINER) > /dev/null

logs_remote:
	ssh -i "wishlist-scrape.pem" ec2-user@winglers-liste.info 'cd wishlist && make logs_local' && \
	scp -r -i "wishlist-scrape.pem" ec2-user@winglers-liste.info:/home/ec2-user/wishlist/logs/nginx/$(PROJECT_NAME)-*.log  ./logs/nginx
	scp -r -i "wishlist-scrape.pem" ec2-user@winglers-liste.info:/home/ec2-user/wishlist/logs/log/output.log  ./logs/log

cert_new: stop
	docker volume create --name "$(VOLUME_LETSENCRYPT)" && \
	docker run -it --rm -p "80:80" -v "$(VOLUME_LETSENCRYPT):/etc/letsencrypt" certbot/certbot certonly --standalone --preferred-challenges http -d winglers-liste.info -d www.winglers-liste.info

cert_renew: stop
	docker run -it --rm -p "80:80" -v "$(VOLUME_LETSENCRYPT):/etc/letsencrypt" certbot/certbot renew --quiet

logs_nginx_access: $(LOG_PRODUCER)
	$(CMD_ACCESS_LOGS)

logs_nginx_error: $(LOG_PRODUCER)
	@cat $(LOG_DIR)/nginx/$(PROJECT_NAME)-error.log

logs_backend: $(LOG_PRODUCER)
	@cat $(LOG_DIR)/log/output.log

stats: $(LOG_PRODUCER)
	goaccess --log-format=COMBINED $(LOG_DIR)/nginx/$(PROJECT_NAME)-access.log

remote:
	ssh -i "wishlist-scrape.pem" ec2-user@winglers-liste.info

clean:
	docker image prune -f --filter label=stage=wishlist-build; \
	rm -rf $(LOG_DIR) tags;

attach_frontend:
	docker exec -i -t $(PROJECT_NAME)_frontend_1 sh

tags:
	ctags -R backend/src
