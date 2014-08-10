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

**run the default task (watch)** which watches the source directory, compiling
and assembling the app as changes are made to the source or spec files that
require compilation

    $ gulp

or **run the release task** which compiles, assembles, and packages the app ready
for deployment to the Chrome web store.

    $ gulp release

## Loading the App (unpacked)

Once the app is built (current revisions should be checked in, but build prior
to loading to ensure their versions are consistent), you can load the unpacked
app from the `APP_ROOT` directory

If you are making changes to the browser itself, load the test harness as well.
It is the same process as loading the unpacked app, just point at `TEST_ROOT`
instead of `APP_ROOT`

## Gulp Tasks

    gulp [TASK]

where `TASK` is one of the following:

* `autobuild`: Watches the `/templates`, `/styles` and `/scripts` directories.
When changes are detected it will compile and assemble the app, ready for
loading into Chrome.

* `watch`: Watches the `/templates` and `/scripts` directories. When changes are
detected, it will initiate the spec runner task, `gulp spec`

* `spec`: Runs the tests/specs for the application. Not yet implemented.

* `assemble`: Takes the source files in `/templates`, `/styles`, `/scripts` and
runs them through their compilers (Handlebars, SASS, CoffeeScript
respectively). The compiled output is concatenated (and minified in the case
of JS), and output into an intermediate directory outside of `APP_ROOT`. The
compiled and minified source from the intermediate directory is then copied
into the appropriate directory in `/APP_ROOT`

* `release`: Performs a clean compilation of the application, resulting in a
package ready to deploy to the Chrome web store. The output archive is
tagged with the version, read from the manifest, of the form:
`<name>-<version>.zip`.  Note that `<name>` is not read from the manifest, but
declared in gulpfile.js

