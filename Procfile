web:            bundle exec rails server -p $PORT
worker:         bundle exec foreman start -f Procfile.workers
# puma:           bundle exec tail -f log/development.log

# NUM_WORKERS=4 delayed_job_worker_pool ./config/delayed_job_worker_pool.rb
# redis:          bundle exec redis-server /usr/local/etc/redis.conf
# sidekiq:        bundle exec sidekiq -C config/sidekiq.yml
# worker:         bundle exec sidekiq -q default -c 2
# worker: bundle exec foreman start -f Procfile.workers
# sidekiq:        RAILS_MAX_THREADS=${SIDEKIQ_RAILS_MAX_THREADS:-15} bundle exec sidekiq -C config/sidekiq.yml
