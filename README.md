folder
Dockerfile
docker-compose file
build web
install bundler
install rails
docker-compose run web .gems/bin/rails new --database=postgresql --skip-action-mailer --skip-action-mailbox --skip-action-text --skip-active-job --skip-active-storage --skip-action-cable --skip-sprockets --skip-spring --skip-listen --skip-javascript --skip-turbolinks --skip-test --skip-system-test --skip-bootsnap --api --minimal --skip-bundle --skip-webpack-install .
sudo rm -fr vendor
rm .browserslistrc
rm .rspec
rm .ruby-version
