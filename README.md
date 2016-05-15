# Service Oriented Architecture in Practice

Construct static HTML site from markdown files.

## Instructions

Clone `service-oriented-architecture-in-practice-book` markdoen files (from folder `service-oriented-architecture-in-practice-online`)

    $ cd ..
    $ git clone https://github.com/shhavel/soabp-book.git

Copy markdown files into folder `views` from `../service-oriented-architecture-in-practice-book`

    $ mkdir views/en-ruby/ views/uk-ruby/ views/ru-ruby/
    $ cp ../service-oriented-architecture-in-practice-book/en-ruby/* views/en-ruby/
    $ cp ../service-oriented-architecture-in-practice-book/uk-ruby/* views/uk-ruby/
    $ cp ../service-oriented-architecture-in-practice-book/ru-ruby/* views/ru-ruby/

Install gems

    $ bundle install

Run `sinatra` application (from root folder in terminal):

    $ rackup -p 4567

Bypass all site pages to generate cached HTML files.

    $ bash crawl.sh

Use HTML files from folder `public`.

## Links

- [Read book online](http://ukrmap.su/en-ruby/index.html)
- [Code examples](https://github.com/shhavel/service-oriented-architecture-in-practice-examples)
- [Customise Bootstrap navbar](http://work.smarchal.com/twbscolor/css/e74c3cc0392becf0f1ffbbbc0)
