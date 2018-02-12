icingaweb2 in Docker
====================

**Note:** This is my own test container, not intended for production use!

This container helps you run Icingaweb2 inside a Docker container.

Icingaweb2 is a modern web interface for the [Icinga](https://www.icinga.com) system monitoring tool.

## How to use this image

Check `docker-compose.example.yml` and `nginx.conf`.

After startup you can configure Icingaweb2 via the setup wizard at `http://localhost:8080/icingaweb2/setup`.

## TODO

Some things in this image need to be done, feel free to contribute!

* Better database integration
* Skipping the setup wizard?
* Describe config of monitoring module
* How to integrate other modules / enable the user to

## License

    Copyright (c) 2016-2018 Icinga Development Team <info@icinga.com>
                  2016-2018 Markus Frosch <lazyfrosch@icinga.com>

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
