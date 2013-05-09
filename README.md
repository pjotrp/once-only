# once-only

[![Build Status](https://secure.travis-ci.org/pjotrp/once-only.png)](http://travis-ci.org/pjotrp/once-only)

Once-only makes a shell script run only once if the inputs don't
change (functional style!). This is very useful when running a range of jobs on a compute
cluster or GRID. It may even be useful in the context of webservices.

Basically you give once-only a command:

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

Note: once-only is written in Ruby, but you don't need to
understand Ruby programming to use it! 

## Installation

```sh
gem install once-only
```

## Usage (command line)

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

