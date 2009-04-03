require 'mongrel_cluster/recipes'

set :application, "deployed-swc-portal"
set :repository,  "http://shrub.ca:8080/svn/swc/portal"
set :deploy_to, "/disk2/home/simon/#{application}"
set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml"
set :use_sudo, false

role :app, "simon@simonwoodside.com"
role :web, "simon@simonwoodside.com"
role :db,  "simon@simonwoodside.com", :primary => true

ssh_options[:paranoid] = false 
