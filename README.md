A youtrack changelog generator.

# Using

    bundle install
    ruby changelog.rb project "project-bundle" http://you-track-url username password

# TODO:

* move credentials to a yaml file ex: ~/.youtrack 
* add opts support --user|-u, --project|-P, --password|-p, --baseurl|-b, --bundle|-B
* add outputfile (last parameter)
* add --reverse options
* add --all-versions (not just released)
* add --no-links => remove links to youtrack
* get versionBundle automagically
