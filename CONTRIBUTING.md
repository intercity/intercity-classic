# Contributing to Intercity

First, thank you for contributing!

We love pull requests from everyone. By participating in this project,
you agree to abide by the [code of conduct](CODE_OF_CONDUCT.md).

Here are a few technical guidelines to follow:

1. Open an issue to discuss a new feature.
2. Write tests.
3. Make sure the entire test suite passes locally and on Codeship.
4. Open a Pull Request.
5. Squash your commits after receiving feedback.
6. Party!

## Security vulnerability disclosure

Please report suspected security vulnerabilities in private to security@intercityup.com.
Please do NOT create publicly viewable issues for suspected security vulnerabilities.
Please refrain from requesting compensation for reporting vulnerabilities.
We will acknowledge receipt of your vulnerability report and send you regular updates
about our progress. If you want we will publicly acknowledge your responsible disclosure.

If you want to encrypt your disclosure email please email us to ask for our PGP key.

## Configure Intercity on your local development environment

### Requirements
* Ruby 2.2.2
* Postgresql
* Redis
* PolarSSL
    * **osx:** `$ brew install polarssl`
    * **linux:** `$ sudo apt-get install libpolarssl-dev`

### Setup

1. After cloning, run the setup script
   `$ bin/setup`
2. Clone the [intercity/chef-repo](https://github.com/intercity/chef-repo) repository.
3. Make sure the data in `$ config/intercity.yml` is correct.
4. Start the vagrant server (needed to run some tests)
   `$ vagrant up`

### Receiving mail

1. To receive mail in development mode you have to install
[mailcatcher](http://mailcatcher.me). `$ gem install mailcatcher`
2. Start mailcatcher with `$ mailcatcher`
3. Go to `http://localhost:1080/` to see the received emails

## Running tests

We use *minitest* as the test suite, which is the default in Ruby 2 and Rails 4.
Run tests with: `$ rake test`

You can also run guard if you prefer: `$ guard`

To make sure the code is following our code guidelines, you can run rubocop
using: `$ rubocop`.
