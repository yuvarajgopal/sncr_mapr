sncr_mapr CHANGELOG
===================

This file is used to list changes made in each version of the sncr_mapr cookbook.

## v0.13.0

* drill configs

## v0.12.0

* spark configs
  * make spark-env a tempate
  * set memory params from attrs
  * do not make master a worker by default

## v0.11.0, v0.11.1

* improve config change detection
* make ecosystem yum repo major version specific

## v0.10.0, v0.10.1, v0.10.2

* update the spark-env.sh to include the public_dna
* try to stop/start slaves when this happens
* add a not_if in case the spark_master has not been created yet
* fix ruby error (missing {} )

## v0.9.1

* in spark_master, protect the reconfigure so it doesn't happen all the time


## v0.9.0

* customize ~mapr/.bashrc

## v0.8.3

* fix missing _ in node index

## v0.8.2

* fix attribute error, missing w in %w

## v0.8.1

* add -p to the -mkdir for /apps/spark

## v0.8.0

* rename attributes
* simplify prereq package loading


## v0.7.0

* rename to sncr_mapr
* remove iptables and selinux recipes
* move their disables to install_pre...


## v0.6.2

* set the core-site.xml action and notifies

## v0.5.0

* fix bug in ::spark_master
## v0.5.0

* install drill

## v0.4.0

* install Apache Spark

## v0.3.2

* add the rpm gpgkey
* turn more ruby blocks into bash blocks

## v0.3.1

* make the /etc/clustershell directory
* this version successfully launched a single node cluster

## v0.3.0

* switch to java cookbook
* some fixes

## v0.2.1

* don't blast root's ssh keys and config


## v0.2.0

0.1.0
-----
- [your_name] - Initial release of sncr_mapr

- - -
Check the [Markdown Syntax Guide](http://daringfireball.net/projects/markdown/syntax) for help with Markdown.

The [Github Flavored Markdown page](http://github.github.com/github-flavored-markdown/) describes the differences between markdown on github and standard markdown.
