# once-only

[![Build Status](https://secure.travis-ci.org/pjotrp/once-only.png)](http://travis-ci.org/pjotrp/once-only)

Relax with PBS!

* Computations only happen once
* A completed job does not get submitted again to PBS
* A job already in the queue does not get submitted again to PBS
* Guarantee independently executed jobs
* Do not worry about submitting serial jobs

and coming

* Automatically use a scratch disk (nyi)
* Garbage collect jobs (nyi)

Once-only makes a program or script run only *once*, provided the inputs don't
change (in a functional style!). This is very useful when running a range of
jobs on a compute cluster or GRID. It may even be useful in the context of
webservices.  Once-only makes it relaxed to run many jobs on compute clusters!
A mistake, interruption, or even a parameter tweak, does not mean everything
has to be run again. When running jobs serially you can just batch
submit them after getting the first results. Any missed jobs can be
run later again. This way you can get better utilisation of the
cluster.

Instead of running a tool or script directly, such as

```sh
  bowtie -t e_coli reads/e_coli_1000.fq e_coli.map
```

Prepend once-only

```sh
  once-only bowtie -t e_coli reads/e_coli_1000.fq e_coli.map
```

and once-only will parse the command line for existing files and run a
checksum on them (here the binary executable 'bowtie' and data files
reads/e_coli_1000.fq and e_coli.map).  This checksum, in fact an MD5
cryptographic hash, or optionally [pfff](https://github.com/pfff/pfff)
for large files, is a unique identifier (aka fingerprint) and saved in
a file in the running directory.  When the checksum file does not
exist in the directory the command 'bowtie -t e_coli
reads/e_coli_1000.fq e_coli.map' is executed.

When the file already exists execution is skipped. In other words, the
checksum file guarantees the program is only run once with the same
inputs. Really simple! 

In combination with PBS this could be

```sh
  echo "once-only bowtie -t e_coli reads/e_coli_1000.fq e_coli.map" |qsub -k oe -d path
```

Interestingly once-only also comes with PBS support, which won't add a job to
the queue if it is already in the queue, or if it has been executed
successfully:

```sh
  once-only --pbs '-k oe' bowtie -t e_coli reads/e_coli_1000.fq e_coli.map
```

The PBS job will be named and identified according to the checksum value.  This
can be used to query PBS and clean up based on queued jobs.

The file once-only writes contains a list of the input files with
their individual checksum values. E.g. on

```sh
./bin/once-only -v ../bioruby-table/bin/bio-table ../bioruby-table/test/data/input/table1.csv 

cat bio-table-25e51f9297b43b5dacf687b4158f0b79e69c6817.txt 

  MD5     53bcceee564c47cebff8160ab734313f          ../bioruby-table/bin/bio-table
  MD5     9868b63e3624023a176c29bb80eb54f5          ../bioruby-table/test/data/input/table1.csv
  SHA1    46ae0f4af8c2566185954bb07d4eeb18c1867077  ../bioruby-table/bin/bio-table ../bioruby-table/test/data/input/table1.csv
```

This list can also be used to distinguish between input and output files after
completion of the program. To check the validity of input files you could run
md5sum on the one-only has file, for example

```sh
grep MD5 bio-table-ce4ceee0d2ee08ef235662c35b8238ad47fed030.txt |awk 'BEGIN { FS = "[ \t\n]+" }{ print $2,"",$3 }'|md5sum -c
```

Once-only is inspired by the Lisp once-only function, which wraps another
function and calculates a result only once, based on the same inputs. It is
also inspired by the NixOS software deployment system, which guarantees
packages are uniquely deployed, based on the source code inputs and the
configuration at compile time.

## Installation

Note: once-only is written in Ruby, but you don't need to understand
Ruby programming to use it! 

With Ruby 1.9 or later on your system you can run

```sh
gem install once-only
```

It is also easy to check out the git repository, as once-only has no
library dependencies.

### Dependencies

'md5sum' is used for calculating MD5 hash values.

'pfff' is optional and used for calculating pfff hash values on very
large files (nyi).

When you are using the --pbs option, once-only will use the 'qsub' and
'qstat' commands.

## Usage (command line)

To get a full list of command options 

```sh
once-only --help
```

Useful switches can be -v (verbose) and -q (quiet).

To skip scanning the executable file (useful in heterogenous environments, 
such as the GRID) use the --skip-exe switch:

```sh
once-only --skip-exe muscle -in aa.fa -out out-alignment.fa -tree1 first.ph -tree2 tree.ph
```

where only aa.fa is the scanned input file in the first round. To prevent the second run
of once-only to include the output files (out-alignment.fa, first.ph and tree.ph) you
can specify them the first round on the command line as

```sh
once-only --skip out-alignment.fa --skip first.ph --skip tree.ph muscle -in aa.fa -out out-alignment.fa -tree1 first.ph -tree2 tree.ph
```

a regular expression on output filenames may be the nicer option

```sh
once-only --skip-exe --skip-regex 'out|\.ph$' muscle -in aa.fa -out out-alignment.fa -tree1 first.ph -tree2 tree.ph
```

or if you are more comfortable with shell style pattern matching use

```sh
once-only --skip-exe --skip-glob 'out*' --skip-glob '*.ph' muscle -in aa.fa -out out-alignment.fa -tree1 first.ph -tree2 tree.ph
```

For a full range of glob patterns, see this [page](http://ruby.about.com/od/beginningruby/a/dir2.htm).

Sometimes you want to include input files that are not on the command
line for generating the hash. Maybe some default input file name is
being picked up, or it is defined in a configuration file. In that
case use the --include/--in options. Another feature is that if an -in
file does not exist once-only does not run.

Another once-only command line option is to change directory before executing the script

```sh
once-only -d run001 --skip-regex 'out|\.ph$' muscle -in aa.fa -out out-alignment.fa -tree1 first.ph -tree2 tree.ph
```

which is useful with PBS and in scripted environments.

### Pipes and redirection

Once-only supports pipes and redirection by stringifying a command on
STDIN:

```sh
echo "/bin/cat README.md > tmp.out" | once-only --skip tmp.out
```

With PBS the tricky thing here is using more quotes for spacing. At this point it is
recommended to escape internal quotes, and avoid using single quotes, e.g.

```sh
echo "/bin/cat \\\"README.md Version 2\\\" > tmp.out" | once-only --pbs --skip tmp.out
```

### PBS

Once-only has PBS support built-in. It only uses the 'qsub' and 'qstat' commands.

Basically use the --pbs option:

```sh
once-only --pbs /bin/cat ~/.bashrc
```

Will submit 'cat ~/.bashrc' to the queue. If the job is already in the queue it 
won't be submitted, thanks to the unique job ID once-only generates.

In fact, this is an interesting example, because
both /bin/cat and ~/.bashrc files may differ on the submission machine and the cluster
nodes. Only when both are the same you can expect once-only to run properly. In 
this case it is wise to add at least

```sh
once-only --pbs --skip-exe /bin/cat ~/.bashrc
```

so once-only won't check the file /bin/cat.

### Guarantee independent jobs with --copy

Because once-only 'knows' the input files we can copy them to a unique
place before execution. By using the --copy switch a new directory is
created in the run directory using the hash value of the process.
Input files are copied and the job is run inside that directory. When
the job is finished the output file(s) are copied back to the working
directory. Example

```sh
once-only --copy /bin/cat ~/.bashrc
```

Note that files that come with a path will be stripped of their path
before execution. When files are very large you may want to consider
the --scratch option.

### Use the scratch disk with --scratch (nyi)

watch this page

### Garbage collect jobs (nyi)

watch this page

## Project home page

Information on the source tree, documentation, examples, issues and
how to contribute, see

  http://github.com/pjotrp/once-only

## Cite

If you use this software, please cite 
  
* [Biogem: an effective tool-based approach for scaling up open source software development in bioinformatics](http://dx.doi.org/10.1093/bioinformatics/bts080)

## Biogems.info

This Biogem is published at http://biogems.info/

## Copyright

Copyright (c) 2013 Pjotr Prins. See LICENSE.txt for further details.

