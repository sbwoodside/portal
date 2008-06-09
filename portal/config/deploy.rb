set :application, "deployed-swc-portal"
set :repository,  "http://shrub.ca:8080/svn/swc/portal"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/disk2/home/simon/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, "simonwoodside.com"
role :web, "simonwoodside.com"
role :db,  "simonwoodside.com", :primary => true