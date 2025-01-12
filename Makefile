hooks:
		cd .git/hooks && ln -s -f ../../hooks/pre-push pre-push

watch:
		@echo "Watching..."
		bundle exec jekyll s -H 127.0.0.1 -l ./ --incremental

build:
		rm -rf ./_site
		bundle exec jekyll b -d "_site"

		bundle exec htmlproofer _site \
				\-\-disable-external=true \
				\-\-ignore-urls "/^http:\/\/127.0.0.1/,/^http:\/\/0.0.0.0/,/^http:\/\/localhost/"

