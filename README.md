icingaweb2 in Docker
====================

This container helps you run Icingaweb2 inside a Docker container.

Icingaweb2 is a modern web interface for the [Icinga](https://www.icinga.org) system monitoring tool.

## How to use this image

    $ docker run --name icingaweb2 --publish 8080:80 --link my-mysql:db -d lazyfrosch/icingaweb2

After startup you can configure Icingaweb2 via the setup wizard at `http://localhost:8080/icingaweb2/setup`.

You can configure the following environment variables:

* `-e ICINGAWEB_SETUP_TOKEN=mysecrettoken` (needed to authenticate you as owner to the setup wizard, default: `docker`)

## Docker Compose

Please checkout the [Docker Compose](docker-compose.yml) file as an example.

If you use the docker example, the database credentials are:

    Host:     db
    Database: icingaweb2
    User:     icingaweb2
    Password: rosebud

## TODO

Some things in this image need to be done, feel free to contribute!

* Better database integration
* Skipping the setup wizard?
* Describe config of monitoring module
* How to integrate other modules / enable the user to

## License

    Copyright (c) 2016 Icinga Development Team <info@icinga.org>
                  2016 Markus Frosch <lazyfrosch@icinga.org>

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
