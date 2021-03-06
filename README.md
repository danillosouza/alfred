# Alfred

Alfred is a command line tool writen in Perl to manage server tasks as Perl modules. It also provides a daemon wich stays listening for new scheduled tasks to be executed and takes care of the job.

## How to get it?

First, you'll ned to clone the repository and instal the dependencies:

```sh
$ git glone https://github.com/danillosouza/alfred.git
$ cd alfred
$ carton install
```
In order to install one of the Perl modules used in Alfred(Net::SSH::Perl), you'll have to install the following package:

```sh
# with apt-get
$ sudo apt-get install libgmp3-dev

# with yum
$ sudo yum install libgmp3-dev
```

Alfred dependencies are managed by Carton, a Perl module to isolate the packages you need to your project, without affecting your global Perl installation.
To get Carton you only need to:

```sh
# if you have cpanminus installed
$ cpanm Carton

# otherwise search by Carton directly into CPAN
$ perl -MCPAN -e install
```


## How do I use it?

Alfred is very simple to use, it provides a few commands:
 * **install**                   - Install itself to the current user path.
 * **daemon**                    - Starts Alfred daemon.
 * **dismiss**                   - Stops Alfred daemon.
 * **list**                      - List all available tasks.
 * **queue**                     - List all tasks currently in the queue.
 * **help <task>**               - Show help information for the given task.
 * **create <task>**             - Create a new task.
 * **purge <task>**              - Destroy the given task.
 * **run <task>**                - Execute the given task.
 * **run:remote <host> <task>**  - Execute the given task in a remote server.
 * **schedule <task>**           - Add the given task to the daemon queue.
 * **cron <crontime> <task>**    - Add a new crontab job to run the given task.

### Some practical examples

After cloning the repository and installing the dependencies, you'll want to install it to your local path, you only need to run:
```sh
$ ./alfred install
$ cd ~
```

Alfred comes with a dummy task named `Foo::Bar` that only shows a massage, you can use it to see how to interact with your tasks:
```sh
$ alfred run Foo::Bar
# Heeeeeey!

$ alfred help Foo::Bar
# Hooooooo!
```

Your tasks can also accept parameters, so if it was the case, you could call it like that:
```sh
$ alfred run My::Task --my --custom --params
```

Naturally, you'll want to create your own tasks, and it's simple:
```sh
$ alfred create My::Task
# He then will show you the path where the Task file was created, so you can code it
```

If you need to see the tasks currently available to you, just run:
```sh
$ alfred list
```

And to remove an existent task:
```sh
$ alfred purge My::Task
```


Beyond this, Alfred can also run as a daemon, so in case you need larger Tasks to be executed, you only need to stack them in the queue so when he's done with the previous Tasks, he will run it:
```sh
# Starts the daemon
$ alfred daemon

# Stack a new task to the queue
$ alfred schedule My::Task

# List all scheduled Tasks
$ alfred queue

# Stops the daemon, if it's running
$ alfred dismiss
```


You can even create a cronjob to run your tasks, let's say you have a task managing your database backups and you need to run it every day at 1:20am, is simple as that:
```sh
# Create a cronjob to run with the current user
$ alfred cron "20 1 * * *" Database::Backup

# If you want to create a cronjob for another user to run, pass the username like this
$ alfred cron "@bruce 20 1 * * *" Database::Backup
```


Alfred also can run tasks in a remote installation. In his root directory you'll find a file called `remotes.yaml`, containing the names and connection data for your remote servers running alfred instances, the file looks like this:
```yaml
---
host1:
    host: 192.168.0.10
    port: 22
    user: your-username
    pass: your-password

host2:
    host: 192.168.0.20
    port: 22
    user: another-username
    pass: another-password
---
```

So when you feel the need to run a task in one of these remote instances, you would call Alfred like this:
```sh
$ alfred run:remote host1 Foo::Bar --my --params
```
