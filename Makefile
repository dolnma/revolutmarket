.PHONY: build

build:
	@cd frontend && npm run build:prod
	@echo "[✔️] Frontend build complete!"

certbot-test:
	@chmod +x ./nginx/prod/register_ssl.sh
	@sudo bash ./nginx/prod/register_ssl.sh \
								--domains "$(DOMAINS)" \
								--email $(EMAIL) \
								--data-path ./ssl/prod \
								--staging 1

certbot-prod:
	@chmod +x ./nginx/prod/register_ssl.sh
	@sudo bash ./nginx/prod/register_ssl.sh \
								--domains "$(DOMAINS)" \
								--email $(EMAIL) \
								--data-path ./ssl/prod \
								--staging 0

dev:
	@docker-compose \
					-f docker-compose.yml \
					-f docker-compose.prod.yml \
					up --build --force-recreate

deploy:
	@docker-compose \
					-f docker-compose.prod.yml \
					up -d --build --force-recreate

ssl-dev:
	@cd ssl/dev
	@openssl \
 			 req -nodes -new -keyout server.key -out server.csr -config server.cnf \
 			 x509 -days 3650 -req -in server.csr -CA root.cer -CAkey root.key -set_serial 123 -out server.cer -extfile server.cnf -extensions x509_ext
	@cp {server.cer,server.csr,server.key} /live/mdolnicek.xxx/
	@echo "[✔️] SSL generated!"
