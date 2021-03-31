# Feed Feeder

Checks RSS feeds for changes and saves new items to your database. Uses [PubSubHubbub](https://github.com/pubsubhubbub/PubSubHubbub) where possible otherwise polls every specified interval. This is used at Lateral to power the news recommendations of [NewsBot](https://getnewsbot.com/).

## Initializing

Run the setup script to install dependencies, create databases and all that jazz:

    bin/setup

## Running

The main components to the application are the rails server, [resque](https://github.com/resque/resque) and [resque-scheduler](https://github.com/resque/resque-scheduler). To start them all for development (after installing foreman `gem install foreman`) run:

    foreman start

For production the services should each be started separately and kept alive through something like `systemd`. For example with:

### Feed Feeder - `/etc/systemd/system/ff.service`

```bash
[Unit]
Description=Feed Feeder
After=multi-user.target

[Service]
User=ubuntu
WorkingDirectory={PROJECT_DIR}
ExecStart={PROJECT_DIR}/bin/puma --tag feed-feeder -e production -b tcp://0.0.0.0:9292
Restart=always

[Install]
WantedBy=multi-user.target
```

### Resque - `/etc/systemd/system/ff-resque@.service`

```bash
[Unit]
Description=Resque #%i
After=multi-user.target

[Service]
User=ubuntu
Environment=RAILS_ENV=production QUEUE=*
WorkingDirectory={PROJECT_DIR}
ExecStart={PROJECT_DIR}/bin/rake -f {PROJECT_DIR}/Rakefile environment resque:work
Restart=always
RuntimeMaxSec=28800

[Install]
WantedBy=multi-user.target
```

### Resque Scheduler - `/etc/systemd/system/ff-resque-scheduler.service`

```bash
[Unit]
Description=Resque Schdeduler
After=multi-user.target

[Service]
User=ubuntu
Environment=RAILS_ENV=production
WorkingDirectory={PROJECT_DIR}
ExecStart={PROJECT_DIR}/bin/rake -f {PROJECT_DIR}/Rakefile environment resque:scheduler
Restart=always
RuntimeMaxSec=28800

[Install]
WantedBy=multi-user.target
```

And then running (untested):

```bash
sudo systemctl enable ff.service
sudo systemctl enable ff-resque@@{1..5}.service
sudo systemctl enable ff-resque-scheduler.service
sudo systemctl start ff.service
sudo systemctl start ff-resque@@{1..5}.service
sudo systemctl start ff-resque-scheduler.service
```
