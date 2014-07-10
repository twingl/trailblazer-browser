# Twingl Browser

This is the combined development container and source repo for the Twingl
Browser in its current incarnation.

It is structured slightly different from a regular Chrome App/Extension in that
there is a significant compile step required to go from source to valid app.

This has been introduced for a couple of reasons, the main ones being that
Handlebars (and indeed most templating libraries) do not fit in with the
content security policies enforced in the Chrome App platform the main one
being that Handlebars (and indeed most templating libraries) do not fit in with
the content security policies enforced in the Chrome App platform. By
pre-compiling Handlebars templates into their respective functions, we can
avoid restrictions around the use of `eval` and function creation at runtime,
which are prohibited by the policies mentioned.

Additionally, we've chosen to use CoffeeScript as the dialect of choice, after
finding that with the Chrome APIs and their liberal use of callbacks, things
can noisy as a result of the mess of brackets/braces left behind.

## Building the App

After installing the dev dependencies...

    $ npm install

...you can:

**run the default task** which watches the source directory, then runs the specs
whenever part of the functional source changes

    $ gulp

(specs are yet to be included)

**run the autobuild task** which watches the source directory, compiling and
assembling the app as changes are made to the source files that require
compilation

    $ gulp autobuild

or **run the release task** which compiles, assembles, and packages the app ready
for deployment to the Chrome web store.

    $ gulp release

## Loading the App (unpacked)

Once the app is built (current revisions should be checked in, but build prior
to loading to ensure their versions are consistent), you can load the unpacked
app from the `APP_ROOT` directory
