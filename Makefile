build:
	bundle exec jekyll build --config _config.yml,_config_dev.yml

server:
	bundle exec jekyll serve --watch --config _config.yml,_config_dev.yml
