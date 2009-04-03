# This is for capistrano

require 'mongrel_cluster/recipes'

set :application, "deployed-swc-portal"
set :repository,  "git://github.com/sbwoodside/portal"
set :scm, "git"
set :deploy_to, "/home/simon/#{application}"
set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml"
set :use_sudo, false

role :app, "simon@new.shrub.ca"
role :web, "simon@new.shrub.ca"
role :db,  "simon@new.shrub.ca", :primary => true

ssh_options[:paranoid] = false 
