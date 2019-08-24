# NAME

XT::Files - standard interface for author tests to find files to check

# VERSION

Version 0.002

# SYNOPSIS

In your distribution, add a `XT::Files` configuration file (optional):

    [Default]
    dirs = 0

    [Dirs]
    bin = script
    module = lib
    test = t
    test = xt

In a `.t` file (optional):

    use XT::Files;

    my $xt = XT::Files->initialize( -config => undef ));
    $xt->bin_dir('bin');
    $xt->module_dir('lib');
    $xt->test_dir('t');

In a `Test` module (optional):

    use Test::XTFiles;

    my @files = Test::XTFiles->new->all_perl_files;

# DESCRIPTION

Author tests often iterate over your distributions files to check them.
Unfortunately, every XT test uses its own code and defaults, to find the files
to check, which means they often don't fit the need of your distribution.
Common problems are not checking `bin` or `script` or, if they do, assuming
Perl files in `bin` or `script` end in `.pl`.

The idea of `XT::Files` is that it's the `Test`s that know what they want
to check (e.g. module files), but it's the distribution that knows where
these files can be found (e.g. in the `lib` directory and in the `t/lib`
directory).

Without `XT::Files` you are probably adding the same code to multiple `.t`
files under `xt` that iterate over a check function of the test.

`XT::Files` is a standard interface that makes it easy for author tests to
ask the distribution for the kind of files it would like to test. And it can
easily be used for author tests that don't support `XT::Files` to have the
same set of files tested with every test.

Note: This is for author tests only. Your own distributions tests already
know which files to test.

# USAGE

## Usage for distribution authors

The distribution can (and should) use an `XT::Files` configuration file.
The default names for the file is either `.xtfilesrc` or `xtfiles.ini`
in the root directory of your distribution. Only one of these files must
exist. If you put it in a different location or name it differently, you
have to load it in every `.t` file

    XT::Files->initialize( -config => 'maint/xt_files.txt' );

The config file contain a global section and a section for every used plugin.
Comments start with either `#` or `;`.

The same plugin can be run multiple times by adding multiple sections with
the same name. Sections of the same name are not merged.

    # require at least this version of XT::Files
    :version = 0.001

    # XT::Files::Plugin::Default
    # the default configuration plugin
    [Default]
    # add the default directories (this is the default)
    dirs = 1
    # add the default excludes (this is the default)
    excludes = 1

    # XT::Files::Plugin::Dirs
    # add directories with the bin_dir, module_dir or test_dir method
    # from XT::Files
    [Dirs]
    bin = maint
    module = maint/lib
    test = maint/t

    # XT::Files::Plugin::Files
    # add files with the bin_file, module_file or test_file method
    # from XT::Files
    [Files]
    bin = maint/config.pl
    pod = maint/contribute.pod
    module = maint/config.pm

    # XT::Files::Plugin::Excludes
    # add exclude patterns
    [Excludes]
    exclude = [.]old$

    # add a directory to @INC to load plugins contained in the distribution
    [lib]
    lib = maint/plugin

    # load a plugin from outside of the XT::Files::Plugin namesapce
    # this is most likely used to load a plugin contained in the distribution
    [=Local::MyPlugin]

The configuration is used to tell tests which files are what. A file can be
of the following types.

- bin

    These are executable Perl files. For most distributions they live in `bin`
    or `script`. They might, or might not, have a `.pl` extension. These files
    might, or might not, contain a Pod documentation.

    You can also add scripts in additional locations, e.g. in `maint` to the
    list of files to be tested with your author tests.

- module

    These are Perl modules. For most distributions they live in the `lib`
    directory. Normally they have a `.pm` extension. These files might, or might
    not, contain a Pod documentation.

- pod

    This is for Pod files. Normally they end in `.pod`. Your scripts or modules
    which contain Pod documentation are not of type pod.

- test

    This is for test files. These files normally have a `.t` extension. Test
    files are also bin files.

All file names should be in UNIX format (forward slashes as directory
separator) as all files found by `XT::Files` are added in this way. If you
add a directory or file with a different directory separator the result
is undefined.

## Usage for author test authors

Writing an author test with `XT::Files` support is straightforward. All you
have to do is decide what kind of files your author test is going to test and
request these files from [Test::XTFiles](https://metacpan.org/pod/Test::XTFiles):

    use Test::XTFiles;

    # all Perl scripts and tests
    my @files = Test::XTFiles->new->all_executable_files;

    # all modules
    my @files = Test::XTFiles->new->all_module_files;

    # all perl files (scripts, modules and tests)
    my @files = Test::XTFiles->new->all_perl_files;

    # all files with Pod in it
    use Pod::Simple::Search;
    my @files = grep { Pod::Simple::Search->new->contains_pod($_) }
        Test::XTFiles->new->all_files;

Don't try to be clever, that's the distributions job. Ask what makes sense to
test - it's the distributions fault if a file is not correctly classified. And
it's much easier for a distribution author to fix the distributions config
file then it is for the test author to guess correctly.

## Methods from XT::Files

All file names passed to methods should be in UNIX format (forward slashes
as directory separator) as all files found by `XT::Files` are added in this
way. If you add a directory with a different directory separator the result
is undefined.

## new( \[ -config => CONFIG \] )

Returns a new `XT::Files` object.

Supports the `-config` argument which needs one of the following arguments.

- `undef`: No configuration is loaded and the object is not initialized.
This can be useful if you would like to build up your configuration
programmatically.
- A file name: The file is `open`ed and the configuration is read from
this file.
- A reference to a string: The configuration is read from this string.

Note: This does neither create the `XT::Files` singleton nor return it.
This is probably not what you want. Unless you know exactly why you need
a `XT::Files` object that differs from the singleton you should use
`initialize` or `instance` which both create and return the singleton.

## initialize ( \[ -config => CONFIG \] )

Checks if the singleton exists and `croak`s if it does. Otherwise calls
`new` with the same arguments and saves the `XT::Files` object returned
by `new` in the singleton, before returning it.

This is most likely the initialization you should use in your `.t` file if
you need the object.

    my $xt = XT::Files->initialize;
    $xt->bin_file('maint/cleanup.pl');

## instance

Checks if the `XT::Files` singleton exists and calls `initialize` without
arguments if it does not. Then returns the singleton.

This method silently discards all arguments. If the singleton does not exist,
it will always use the default configuration which is the `XT::Files` config
file or, if that does not exist, the [XT::Files::Plugin::Default](https://metacpan.org/pod/XT::Files::Plugin::Default) plugin.

This is the method that is called by [Test::XTFiles](https://metacpan.org/pod/Test::XTFiles)'s `new` method.

## files

Returns all files to be tested as [XT::Files::File](https://metacpan.org/pod/XT::Files::File) objects.

You should probably use one or multiple of the methods of [Test::XTFiles](https://metacpan.org/pod/Test::XTFiles)
if you need to obtain a list of files to be tested, either in a `Test`
test or in a `.t` test file.

## exclude( PATTERN )

Adds an exclude pattern. The `files` method tries to match the basename of
every file against these patterns and skips the file if it matches.

Use this to exclude temporary or backup files you have in your workspace.

## bin\_dir( DIRECTORY )

Scans the directory for files and adds them all as executable files. Files
that already have an entry are skipped.

There are no further checks that every file in the directory is a Perl
script. Use this method to add directories like `bin` or `script`.

If you have a directory that contains Perl scripts and other files, add them
selectively with `bin_file` from within your `.t` test file or use the
[XT::Files::Plugin::Files](https://metacpan.org/pod/XT::Files::Plugin::Files) plugin from your configuration file.

## module\_dir( DIRECTORY )

Scans the directory for files and adds all files ending in `.pm` as module
file and every file ending in `.pod` as pod file. Other files are skipped.
Files that already have an entry are skipped.

## test\_dir( DIRECTORY )

Scans the directory for files and adds all files anding in `.t` as test
file. Other files are skipped. Files that already have an entry are skipped.

## bin\_file( FILENAME )

Adds the file FILENAME to the list of files to be tested and marks it as a
Perl script file. If there is already an entry for FILENAME, the existing
entry is replaced with a new entry.

## ignore\_file( FILENAME )

Ignores a file from being tested. This method adds an `undef` entry for
FILENAME. Use this to e.g. remove a single file from a directory:

    $xt->bin_dir('maint');
    $xt->ignore_file('maint/bugs.csv');

## module\_file( FILENAME )

Adds the file FILENAME to the list of files to be tested and marks it as a
Perl module file. If there is already an entry for FILENAME, the existing
entry is replaced with a new entry.

## pod\_file( FILENAME )

Adds the file FILENAME to the list of files to be tested and marks it as a
Pod file. If there is already an entry for FILENAME, the existing
entry is replaced with a new entry.

A Pod file is a file which typically ends in `.pod`. This is not for other
files (e.g. modules or scripts) that also contain Pod.

## remove\_file( FILENAME )

Removes the entry for FILENAME from the list of files to be tested.

This differs from `ignore_file` in that later calls to the `*_dir` methods
can add a new file for a removed file, but not for an ignored file.

## test\_file( FILENAME )

Adds the file FILENAME to the list of files to be tested and marks it as a
test file. If there is already an entry for FILENAME, the existing
entry is replaced with a new entry.

## file( FILENAME, \[ FILE OBJECT \] )

Returns the file entry for FILENAME when called with a single argument.

With two arguments, the FILE OBJECT must either be `undef` or a
[XT::Files::File](https://metacpan.org/pod/XT::Files::File) object.

You should probably use one of the existing `*_file` methods to add new
files but this method can be used to e.g. add a modulino.

    my $file = XT::Files::File->new(
        name => 'bin/my_modulino',
        is_module => 1,
        is_script => 1
    );
    $xt->file($file->name, $file);

## plugin( NAME, VERSION, KEYVALS\_REF )

Loads and runs a plugin. All plugins must have a `new` and a `run` method.

If the name starts with a `=`, the leading `=` is removed and the remaining
string is used as package name. Otherwise `XT::Files::Plugin::` is prepended
to the string and this is used as package name.

The `plugin` method uses [Module::Load](https://metacpan.org/pod/Module::Load) to load the plugin. If a VERSION
is defined it checks that [version](https://metacpan.org/pod/version)s `parse` of the VERSION isn't lower
then the plugins version. VERSION can be undef which means every version is
accepted.

Then it calls the plugins `new` method and passes `$self` as the `xtf`
argument and expects an object of the plugin in return.

    my $plugin_object = NAME->new( xtf => $self );

After that it calls the plugins `run` method and passes it the KEYVALS\_REF.

# EXAMPLES

## Example 1 Use a test that supports `XT::Files` with default config

Because the [Test::Pod::Links](https://metacpan.org/pod/Test::Pod::Links) supports `XT::Files` we can just use the
following two lines for our author test `.t` file.

    use Test::Pod::Links 0.003;

    all_pod_files_ok();

When `Test::Pod::Links` asks `XT::Files` for all the pod files to check,
`XT::Files` checks if the distribution has an `XT::Files` config file.
If the config file exists it is parsed and processed, otherwise the
[XT::Files::Plugin::Default](https://metacpan.org/pod/XT::Files::Plugin::Default) is loaded to load the default `XT::Files`
configuration.

## Example 2 Use a test that supports XT::Files with default config files

In your distribution's `.xtfilesrc` or `xtfiles.ini` file you can configure
the structure of your distribution.

    [Default]
    dirs=0

    [Dirs]
    bin = bin
    module = lib
    test = t
    test = xt

The run the test the same as in Example 1

    use Test::Pod::Links

    all_pod_files_ok();

But this time the file list is generated depending on your config file and not
on the defaults from the [XT::Files::Plugin::Default](https://metacpan.org/pod/XT::Files::Plugin::Default) plugin.

## Example 3 Use a test that supports `XT::Files` but ignore default config file

The following example lets you programmatically configure the `XT::Files`
file list omitting a config file, if it exists and only loading the excludes
config from the [XT::Files::Plugin::Default](https://metacpan.org/pod/XT::Files::Plugin::Default) plugin.

We recommend that you always configure `XT::Files` with a config file but
this example could be used if some special logic is required.

    use XT::Files;
    use Test::Pod::Links

    my $xt = XT::Files->initialize( -config => undef );

    $xt->plugin( 'Default', undef, [ dirs => 0 ] );

    $xt->bin_dir('bin');
    $xt->lib_dir('lib');
    $xt->test_dir('t');
    $xt->test_dir('xt');

    all_pod_files_ok();

## Example 4 Use a test that supports `XT::Files` with the config file but add test directory

This initializes the config, either from the config file or, if no config
file exists, with the [XT::Files::Plugin::Default](https://metacpan.org/pod/XT::Files::Plugin::Default) plugin. Then it adds
an additional two directories. This can be used if you want to check some
files with only some author tests.

    use XT::Files;
    use Test::Pod::Links

    my $xt = XT::Files->instance;
    $xt->test_dir('t');
    $xt->test_dir('xt');

    all_pod_files_ok();

## Example 5 Use a test that does not support `XT::Files`

If a test does not support `XT::Files` we have to fall back to the old
iterating over the files and call the `files_ok` (or similar) function.
This allows us to use the same logic to generate the file list as all tests
that support `XT::Files` use.

    use Test::More 0.88;
    use Test::XTFiles;
    use Test::Something;

    for my $file (Test::XTFiles->new->all_files()) {
      files_ok($file);
    }

    done_testing();

# ENVIRONMENT

## XT\_FILES\_DEFAULT\_CONFIG\_FILE

The `XT_FILES_DEFAULT_CONFIG_FILE` environment variable can be used to
specify a different default config file.

The variable must contain the path to a file that can be read.

This specifies only the default config file. This file is only used if
`XT::Files` is initialized with the default config file.

# SEE ALSO

[Test::XTFiles](https://metacpan.org/pod/Test::XTFiles),
[XT::Files::File](https://metacpan.org/pod/XT::Files::File),
[XT::Files::Plugin::Default](https://metacpan.org/pod/XT::Files::Plugin::Default),
[XT::Files::Plugin::Dirs](https://metacpan.org/pod/XT::Files::Plugin::Dirs),
[XT::Files::Plugin::Excludes](https://metacpan.org/pod/XT::Files::Plugin::Excludes),
[XT::Files::Plugin::Files](https://metacpan.org/pod/XT::Files::Plugin::Files),
[XT::Files::Plugin::lib](https://metacpan.org/pod/XT::Files::Plugin::lib),
[XT::Files::Plugin](https://metacpan.org/pod/XT::Files::Plugin),
[XT::Files::Role::Logger](https://metacpan.org/pod/XT::Files::Role::Logger)

# SUPPORT

## Bugs / Feature Requests

Please report any bugs or feature requests through the issue tracker
at [https://github.com/skirmess/XT-Files/issues](https://github.com/skirmess/XT-Files/issues).
You will be notified automatically of any progress on your issue.

## Source Code

This is open source software. The code repository is available for
public review and contribution under the terms of the license.

[https://github.com/skirmess/XT-Files](https://github.com/skirmess/XT-Files)

    git clone https://github.com/skirmess/XT-Files.git

# AUTHOR

Sven Kirmess <sven.kirmess@kzone.ch>

# COPYRIGHT AND LICENSE

This software is Copyright (c) 2018-2019 by Sven Kirmess.

This is free software, licensed under:

    The (two-clause) FreeBSD License
