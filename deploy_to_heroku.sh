RAILS_ENV=production bundle exec rake assets:precompile
git add --all 
git commit -m "Improve layout"
git push heroku master
