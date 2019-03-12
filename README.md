# Google Books Driver
[![Build Status](https://travis-ci.org/hirmeos/google_books_driver.svg?branch=master)](https://travis-ci.org/hirmeos/google_books_driver) [![Release](https://img.shields.io/github/release/hirmeos/google_books_driver.svg?colorB=58839b)](https://github.com/hirmeos/google_books_driver/releases) [![License](https://img.shields.io/github/license/hirmeos/google_books_driver.svg?colorB=ff0000)](https://github.com/hirmeos/google_books_driver/blob/master/LICENSE)


## Credentials
Google does not provide an API to retrieve Google Books traffic reports, therefore we cannot use OAuth tokens for authentication. This driver runs selenium to login to Google using plain credentials (i.e. a Google account email and password) and obtain the traffic report.

We recommend creating a Google account specifically for this purpose, instead of using existing personal credentials. Needless to say that this account must be granted access to the publisher's Google Play Books page.


## Run via crontab
```
0 0 * * 0 docker run --rm --name "google_books_driver" --env-file /path/to/config.env -v /somewhere/to/store/analysis:/usr/src/app/cache -v /somewhere/to/store/output:/usr/src/app/output openbookpublishers/google_books_driver
```
