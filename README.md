# Service Oriented Architecture in Practice

Construct static HTML site from markdown files.

## Instructions

Clone `soabp-book` markdoen files (from folder `soabp-online`)

    $ cd ..
    $ git clone https://github.com/shhavel/soabp-book.git

Copy markdown files into folder `views` from `../soabp-book`

    $ cp ../soabp-book/en-ruby views
    $ cp ../soabp-book/uk-ruby
    $ cp ../soabp-book/ru-ruby

Install gems

    $ bundle install

Run `sinatra` application (from root folder in terminal):

    $ ruby application.rb

Bypass all site pages to generate cached HTML files. 

    $ bash crawl.sh

Use HTML files from folder `public`.

## Links

- [Read book online](http://ukrmap.su/en-ruby/index.html)
- [Code examples](https://github.com/shhavel/service-oriented-architecture-in-practice)
- [Customise Bootstrap navbar](http://work.smarchal.com/twbscolor/css/e74c3cc0392becf0f1ffbbbc0)
