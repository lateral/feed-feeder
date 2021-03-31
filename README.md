# Feed Feeder

Checks RSS feeds for changes and saves new items to your database. Uses [PubSubHubbub](https://github.com/pubsubhubbub/PubSubHubbub) where possible otherwise polls every specified interval. This is used at Lateral to power the news recommendations of [NewsBot](https://getnewsbot.com/).

## Initializing

Run the setup script to install dependencies, create databases and all that jazz:

    bin/setup

## Running

The main components to the application are the rails server, [resque](https://github.com/resque/resque) and [resque-scheduler](https://github.com/resque/resque-scheduler). To start them all for development (after installing foreman `gem install foreman`) run:

    foreman start

For production the services should each be started separately and kept alive through something like systemd.
