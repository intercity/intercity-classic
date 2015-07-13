# Installation manual

## Select version to install

Make sure you view the installation guide from the tag (version) of Intercity
you would like to install. In most cases this should be the highest numbered
production tag (without rc in it).

## Requirements

* Ubuntu 14.04
* At least 512 MB ram, more is better

## Overview

The Intercity installation consists of setting up the following components:

1. Packaged / Dependencies
2. Ruby
3. System Users
4. Database
5. Redis
6. Chef-repo
7. Intercity
8. Nginx / Passenger

## 1. Packages / Dependencies

Install the required packages (needed to compile Ruby and native extensions to
Ruby gems):


```shell
sudo apt-get update -y
sudo apt-get install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libpolarssl-dev tcl8.5 nodejs
```

## 2. Install Ruby

Remove the old Ruby 1.8 if present

```shell
sudo apt-get remove ruby1.8
```

Download Ruby and compile it:

```shell
mkdir /tmp/ruby && cd /tmp/ruby
curl -L --progress http://cache.ruby-lang.org/pub/ruby/2.2/ruby-2.2.2.tar.gz | tar xz
cd ruby-2.2.2
./configure --disable-install-rdoc
make
sudo make install
```

Install the Bundler Gem:

```shell
sudo gem install bundler --no-ri --no-rdoc
```

## 3. System Users

Create a `intercity` user for Intercity:

```shell
sudo adduser --disabled-login --gecos 'Intercity' intercity
```

## 4. Database

The official way to use Intercity is via a PostgreSQL database. You might be
able to run it using MySQL, but you're on your own with that.

```shell
# Install the database packages
sudo apt-get install -y postgresql postgresql-client libpq-dev

# Login to Postgres
sudo -u postgres psql -d template1

# Create an user for Intercity
template1=# CREATE USER intercity CREATEDB;

# Create the Intercity production database & grant all privileges on the database
template1=# CREATE DATABASE intercity_production OWNER intercity;

# Quit the database session
template1=# \q

# Try connecting to the new database with the new user
sudo -u intercity -H psql -d intercity_production

# Quit the database session
intercity_production> \q
```

## 5. Redis

```shell
curl http://download.redis.io/releases/redis-3.0.2.tar.gz | tar xz
cd redis-3.0.2
make
make test
make install
./utils/install_server.sh
```

## 7. Chef-repo

Intercity makes use of the chef-repo for installing your servers. We need to
make sure this is present on your server before we install the rest of
Intercity.

```shell
cd /home/intercity
sudo -u intercity -H git clone https://github.com/intercity/chef-repo chef-repo
cd chef-repo
sudo -u intercity -H git checkout v2.5.0
sudo -u intercity -H bundle install --deployment --without development test
sudo -u intercity -H bundle exec librarian-chef install
```

## 6. Intercity

Since we will install Intercity into the home directory of the user "intercity"
we change to that directory:

```shell
cd /home/intercity
```

### Clone the source

```shell
  sudo -u intercity -H git clone https://github.com/intercity/intercity.git -b path-to-opensource intercity
```
**note** you can checkout master if you want the bleeding edge version, but
never install master on production servers!

### Configure it

```shell
# Go to the Intercity installation folder
cd /home/intercity/intercity

# Copy the example Intercity config
sudo -u intercity -H cp config/intercity.example.yml config/intercity.yml

# Generate a new encryption key and copy it
sudo -u intercity -H bin/generate_encryption_key

# Update the Intercity config file with the new encryption key
sudo -u intercity -H editor config/intercity.yml

# Copy database configuration file
sudo -u intercity -H cp config/database.yml.example config/database.yml
sudo -u intercity -H chmod o-rwx config/database.yml

# Create necessary folders
sudo mkdir tmp/
sudo mkdir log/
sudo chown -R intercity log/
sudo chown -R intercity tmp/
sudo chmod -R u+rwX,go-w log/
sudo chmod -R u+rwX tmp/
```

### Install Gems

```shell
sudo -u intercity -H bundle install --deployment --without development test
```

### Initialize database

```shell
sudo -u intercity -H rake db:schema:load RAILS_ENV=production
```

### Install assets

```shell
sudo -u intercity -H bundle exec rake assets:precompile RAILS_ENV=production
```

### Create first user

In order to create the first administrator user you need to log in to the rails
console and create the user in there.

```shell
sudo -u intercity -H bin/rails console production

# The following commands need to be entered inside the rails console

irb(main)> User.create!(full_name: "Admin", email: "your_email@example.com", password: "Your secure password", admin: true)
irb(main)> exit
```

## 7. Nginx / Passenger

```shell
bin/setup_passenger
```

## Done!
