# once-only

[![Build Status](https://secure.travis-ci.org/pjotrp/once-only.png)](http://travis-ci.org/pjotrp/once-only)

Once-only makes a shell script run only once if the inputs don't
change (functional style!). This is very useful when running a range of jobs on a compute
cluster or GRID. It may even be useful in the context of webservices.

You give once-only a command:

```sh
  once-only bowtie -t e_coli reads/e_coli_1000.fq e_coli.map
```

Once-only will parse the command line for existing files and run a
checksum on them (here the binary executable 'bowtie' and data files
reads/e_coli_1000.fq and e_coli.map).  This checksum is saved in a
file in the running directory. When the checksum file does not exist
the command 'bowtie -t e_coli reads/e_coli_1000.fq e_coli.map' is
executed.

Otherwise execution is skipped. Simple! 

In combination with PBS this could be

```sh
  echo "once-only bowtie -t e_coli reads/e_coli_1000.fq e_coli.map" |qsub -k oe -d path
```

Interestingly once-only also comes with some PBS support, which won't add a job to the queue if it
has been executed successfully:

```sh
  once-only --pbs '-k oe -d path' bowtie -t e_coli reads/e_coli_1000.fq e_coli.map
```

The PBS job will be named and identified according to the Hash value.
This can be used to query PBS and clean up based on queued jobs.

The file once-only writes contains a list of the input files with
their MD5 finger print values. E.g. on


```sh
./bin/once-only -v ../bioruby-table/bin/bio-table ../bioruby-table/test/data/input/table1.csv 

cat bio-table-25e51f9297b43b5dacf687b4158f0b79e69c6817.txt 

  MD5     53bcceee564c47cebff8160ab734313f          ../bioruby-table/bin/bio-table
  MD5     9868b63e3624023a176c29bb80eb54f5          ../bioruby-table/test/data/input/table1.csv
  SHA1    46ae0f4af8c2566185954bb07d4eeb18c1867077  ../bioruby-table/bin/bio-table ../bioruby-table/test/data/input/table1.csv
```

This list can be used to distinguish
between input and output files after completion of the program.

## Installation

Note: once-only is written in Ruby, but you don't need to understand
Ruby programming to use it! 

With Ruby 1.9 or later on your system you can run

```sh
gem install once-only
```

## Usage (command line)

To get a full list of command options 

```sh
./bin/once-only --help
```

Useful switches can be -v (verbose) and -q (quiet).

If you want to skip scanning the executable file (useful in heterogenous environments, 
such as the GRID) use the --skip-exe switch:

```sh
once-only --skip-exe muscle -in aa.fa -out out-alignment.fa -tree1 first.ph -tree2 tree.ph
```

where only aa.fa is the scanned input file in the first round. To prevent the second run
of once-only to include the output files (out-alignment.fa, first.ph and tree.ph) you
can specify them the second round on the command line as

```sh
once-only --skip-exe --skip out-alignment.fa --skip first.ph --skip tree.ph muscle -in aa.fa -out out-alignment.fa -tree1 first.ph -tree2 tree.ph
```

a regular expression on file names may be the nicer option

```sh
once-only --skip-exe --filter 'out|\.ph$' muscle -in aa.fa -out out-alignment.fa -tree1 first.ph -tree2 tree.ph
```

## API

Once-only also has a programmers API for Ruby.

```ruby
require 'once-only'
```

The API doc is online. For more code examples see the test files in
the source tree (NYI).
        
## Project home page

Information on the source tree, documentation, examples, issues and
how to contribute, see

  http://github.com/pjotrp/once-only

## Cite

If you use this software, please cite 
  
* [Biogem: an effective tool-based approach for scaling up open source software development in bioinformatics](http://dx.doi.org/10.1093/bioinformatics/bts080)

## Biogems.info

This Biogem is published at (http://biogems.info/index.html#once-only)

## Copyright

Copyright (c) 2013 Pjotr Prins. See LICENSE.txt for further details.

