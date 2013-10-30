How to run these tests?
=======================

Installing the framework
------------------------

These tests have been written using the MySQL Test Framework.
If you want to run them, you'll need to install it first.
You'll find the installation instructions at the official manual: [The MySQL Test Framework, Version 2.0](http://downloads.mysql.com/docs/mysqltest-2.0-en.pdf).

In my case (I'm running a MariaDB Server over a Debian Operating System), I've just done:

> apt-get install mariadb-server

Running the tests
-----------------

To run these tests, you'll need to navigate to your mysql-test folder (for instance, /usr/share/mysql/mysql-test).
Then, you'll have to copy all of these tests into the suite folder. Assuming that you have the sources of the
dataquality project in /opt/dataquality, you'll have to do something like:

> mkdir /usr/share/mysql/mysql-test/suite/dataquality
>
> cp -R /opt/dataquality/test/mysql/* /usr/share/mysql/mysql-test/suite/dataquality

Then you'll need to configure your connection parameters. To make it easier for you, you can rename the my.cnf.example
as my.cnf (leaving it into the folder where it's located) and then edit it with your connection info.

Finally, you can run the commands by executing:

> cd /usr/share/mysql/mysql-test
> 
> ./mysql-test-run.pl --suite=dataquality
