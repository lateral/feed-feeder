# Feed Feeder

Checks RSS feeds for changes and saves new items to your database. Uses [PubSubHubbub](https://github.com/pubsubhubbub/PubSubHubbub) where possible otherwise polls every specified interval.

## Initializing

Run the setup script to install dependencies, create databases and all that jazz:

	bin/setup

## Running

Use [Pow](http://pow.cx/) to get the website up and running at `http://feed-feeder.dev`. Then in the apps directory run:

	foreman start

To start [resque](https://github.com/resque/resque) and [resque-scheduler](https://github.com/resque/resque-scheduler).
