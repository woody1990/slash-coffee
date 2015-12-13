# /coffee

/coffee is a slash command to organize coffee runs through slack.

Each run is created on a channel level, meaning that different channels can have separate runs simultaneously (if you have a global team, for example).

## Installation

The command is not yet packaged as a slack app, so you're going to have to roll your own for now.

To do so:

1. Clone this repository
2. Deploy it you your server of choice ([Heroku](http://heroku.com/) works well)
3. Go to your slack teams integration list
4. Add a slash command for `/coffee`
5. Set it to point to your url with a '/coffee' at the end
6. Set the method to `POST`
7. Name it whatever you like and fill in all the descriptions if you wish
8. Done! :tada:

## Usage

There are 5 commands to know:

### `/coffee run [time]`

Start a coffee run!
example: `/coffee run 15`

### `/coffee list`

Show the list of orders for the current run.
example: `/coffee list`

### `/coffee order [item]`

Order something from the current run.
example: `/coffee order small cappuccino`

### `/coffee here`

Let everyone know that the coffee is here!
This is needed so that others can start new runs later on.
example: `/coffee here`

### `/coffee help`

Show a help message detailing the available commands.
example: `/coffee help`

## Contributing

Feel free to fork this repository, add anything you like and open a pull request!

:coffee::runner:
