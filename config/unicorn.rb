# Minimal sample configuration file for Unicorn (not Rack) when used
# with daemonization (unicorn -D) started in your working directory.
#
# See https://bogomips.org/unicorn/Unicorn/Configurator.html for complete
# documentation.
# See also https://bogomips.org/unicorn/examples/unicorn.conf.rb for
# a more verbose configuration using more features.

# listen 2007 # by default Unicorn listens on port 8080
worker_processes ENV["UNICORN_PROCESSES"].to_i # this should be >= nr_cpus
pid "/usr/src/app/unicorn.pid"
logger Logger.new($stdout)
