# Google Books Driver
[![Build Status](https://travis-ci.org/hirmeos/google_books_driver.svg?branch=master)](https://travis-ci.org/hirmeos/google_books_driver) [![Release](https://img.shields.io/github/release/hirmeos/google_books_driver.svg?colorB=58839b)](https://github.com/hirmeos/google_books_driver/releases) [![License](https://img.shields.io/github/license/hirmeos/google_books_driver.svg?colorB=ff0000)](https://github.com/hirmeos/google_books_driver/blob/master/LICENSE)

- Documentation: https://metrics.operas-eu.org/docs/google-books

This driver allows programmatic retrieval and normalisation of Goole Books usage reports.

The driver is made of two modules: the first one scrapes usage reports from Google Books and stores them in a directory (`CACHEDIR`); the second reads from cache, normalises the reports, and outputs to a different directory (`OUTDIR`). We recommend running this driver in a docker container and mapping both `CACHEDIR` and `OUTDIR` to persistent volumes.

## Setup
### Requirements
Identifier normalisation is performed using an instance of [hirmeos/identifier_translation_service][1] - you must first setup this API.

### Credentials
Google does not provide an API to retrieve Google Books traffic reports, therefore we cannot use OAuth tokens for authentication. This driver runs selenium to login to Google using plain credentials (i.e. a Google account email and password) and obtain the traffic report.

We recommend creating a Google account specifically for this purpose, instead of using existing personal credentials. Needless to say that this account must be granted access to the publisher's Google Play Books page.

### Environment variables
The following environment variables must be set. You can find a template in `./config/config.env.example`.

| Variable        | Description                                                                      |
| --------------- | -------------------------------------------------------------------------------- |
| `MODES`         | A JSON array containing further configuration (see below).                       |
| `WORK_TYPES`    | All the pertinent work types to query in the translation service.                |
| `USER_AGENT`    | The user agent to use with phantomjs.                                            |
| `GOOGLE_USER`   | The email address of a google account with access to the reports.                |
| `GOOGLE_PASS`   | The password for the above google account.                                       |
| `OUTDIR`        | The path to the directory where the driver will store its output.                |
| `CACHEDIR`      | The path to the directory where the driver will store the raw reports.           |
| `URI_API_ENDP`  | The URL to the translation service.                                              |
| `AUTH_API_ENDP` | The URL to the tokens API.                                                       |
| `URI_API_USER`  | The email address of the user with access to the translation service.            |
| `URI_API_PASS`  | The password of the above user.                                                  |
| `URI_SCHEME`    | The desired URI scheme to normalise identifiers to (we recommend DOI, info:doi). |
| `URI_STRICT`    | Whether to output errors with ambiguous translation queries.                     |
| `CUTOFF_DAYS`   | The driver will get reports until today minus `CUTOFF_DAYS`.                     |

### Example `config.env` file
```
MODES=[{"measure":"https://metrics.operas-eu.org/google-books/views/v1","name":"google-books","startDate":"2010-01-01","config": [{"name":"account","value":"0123456789012345678"}]}]
USER_AGENT="Mozilla/5.0 (Windows NT 6.1; WOW64; rv:25.0) Gecko/20100101 Firefox/25.0"
WORK_TYPES=["book","book-series","book-set","dissertation","edited-book","journal","journal-issue","journal-volume","monograph","posted-content","proceedings","reference-book","report","report-series","standard","standard-series"]
GOOGLE_USER=agoogleaccount@gmail.com
GOOGLE_PASS=a_secret_google_password
OUTDIR=/usr/src/app/output
CACHEDIR=/usr/src/app/cache
URI_API_ENDP=https://identifier.translation.service/translate
AUTH_API_ENDP=https://authentication.service/tokens
URI_API_USER=admin_user@openbookpublishers.com
URI_API_PASS=some_secret_password
URI_SCHEME=info:doi
URI_STRICT=false
CUTOFF_DAYS=1
```

### The `MODES` env variable
You must define a JSON array in`MODES`, with at least one record. The driver will iterate through the array, performing its task once per mode; in a typical case there will only be one entry in the array, however this configuration allows one single driver to query reports from multiple google books accounts.

Each entry of the `MODES` array must contain values for `measure`, `name`, `startDate`, and `config`.

| Attribute   | Description                                                                                                     |
| ----------- | --------------------------------------------------------------------------------------------------------------- |
| `measure`   | A URI identifying the type of measure. You may use https://metrics.operas-eu.org/google-books/views/v1          |
| `name`      | The name of this mode. This is not too important, though it is used as the prefix of cache and output files.    |
| `startDate` | The first date in which your account has usage data available in Google Books (YYYY-MM-DD format)               |
| `config`    | An array containing one single object containing the unique ID of your Google Books account (see example below) |

Example:
```
MODES=[{"measure":"https://metrics.operas-eu.org/google-books/views/v1","name":"google-books","startDate":"2010-01-01","config":[{"name":"account","value":"0123456789012345678"}]}]
```

## Run via crontab
```
0 0 * * 0 docker run --rm --name "google_books_driver" --env-file /path/to/config.env -v google_books_cache:/usr/src/app/cache -v metrics:/usr/src/app/output openbookpublishers/google_books_driver
```

## Troubleshooting
It is very important to check the output the first time the driver is run as it is very likely that Google will block the 'suspicious' login attempt. If it does, you will need to login with the same credentials you have provided the driver with and review the security settings, Google will ask if you were prevented from logging in and you must confirm so. Afterwards re-run the driver and it should work just fine.

The error "Failed to retrieve report x-y. This is likely to be caused by an authentication issue" will be printed to standard error whenever the driver is not able to fetch a report. In most cases this simply means that the scraper did not manage to singin properly for that particular report, and a second iteration of the driver will solve the issue. However, if the error persists for the whole date range it is worth checking that Google is not blocking the signin attempt; otherwise you may simply ignore the error as it will eventually fix itself.

[1]: https://github.com/hirmeos/identifier_translation_service "Identifier Translation Service"
