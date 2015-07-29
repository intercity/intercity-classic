# Intercity

[![Build Status](https://semaphoreci.com/api/v1/projects/bb80760f-43e8-43ba-9bff-0c6b125b40e1/482459/shields_badge.svg)](https://semaphoreci.com/jvanbaarsen/intercity)

Simple web control panel for hosting Rails apps.

Intercity is a web control panel that lets you host Ruby on Rails (or other Rack
based apps) on your own servers. You can use it to manage servers from vendors
like DigitalOcean, Linode, AWS or any other local server/VPS vendor. Intercity
is also great for managing servers in your own datacenter.

Intercity configures your servers to host multiple Ruby on Rails apps and stages on
single servers. It creates databases, generates secure passwords and installs
your server with all the community best practices out there for hosting Ruby on
Rails apps.

## Requirements

* Any Ubuntu 14.04 LTS server.
* At least 512 MB ram, more is better

## Installation

See the [doc/installation][2] guide for a detailed installation instruction.
Need help? Don't hestitate to open an issue!

## Contributing

See the [CONTRIBUTING][1] guide on the how you can contribute, and how to get the
project running locally. Please make sure you've read the [CODE_OF_CONDUCT][4].

## Continuous Integration

CI is hosted with [Semaphoreapp][3]. The build is run automatically whenever any
branch is updated on GitHub.

[1]: CONTRIBUTING.md
[2]: doc/installation.md
[3]: https://semaphoreapp.com
[4]: CODE_OF_CONDUCT.md
