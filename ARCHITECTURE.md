# Architecture

The browser is structured similarly to a web app, in keeping with Ember's
conventions. Where possible, existing conventions (the use of resourceful
routes, for instance) are used if they fit the functionality.

## App Structure

There are three *main* states in the browser.

1. Not authenticated and on the log in screen
2. Authenticated and on the Assignment selection screen
3. Authenticated and in browsing mode with an Assignment selected

These correspond to the following routes and controllers:

1. Signed out
  - `LoginController`
  - `/login`

2. Signed in, no assignment selected
  - `AssignmentsController`
  - `/assignments`

3. Signed in, assignment selected
  - `BrowserController`
  - `/assignments/:assignment\_id/browser`

Additionally, there is some global functionality that needs to be consistent
across all views in the application. The extent of this is currently only the
window management functions, and those are handled in `ApplicationController`

## The Browser

The browser itself is somewhere we deviate slightly from a traditional web app.
It is made up of two main parts, the browsing interface and the trail
interface. `BrowserController` manages both of these.
