set :branch, 'wmf-staging'
set :rails_env, 'staging'

role :app, %w(awight@wikiedu-dashboard-staging.globaleducation.eqiad.wmflabs)
role :web, %w(awight@wikiedu-dashboard-staging.globaleducation.eqiad.wmflabs)
role :db,  %w(awight@wikiedu-dashboard-staging.globaleducation.eqiad.wmflabs)

set :user, 'awight'
set :address, 'wikiedu-dashboard-staging.globaleducation.eqiad.wmflabs'

set :deploy_to, '/var/www/dashboard'
