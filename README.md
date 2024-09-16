# Google calendar events
##  This project is a google calenar built with Ruby on Rails.
<hr />

### Introduction

This app integrate google calendar with rails, users can create events in the app and send them to their google calendar.

You will find following items in this app

* Tailwindcss for design
* Devise implemented where user can signin in using their gmail accounts
* Google Calendar API


## Development Setup

Prerequisites:

- PostgreSQL
- Bundler
- Ruby(3.2.2)
- Rails 7

```sh
bundle install
```
And to setup the database you can run these commands

```sh
rails db:create
rails data:migrate
```
Now you are all set. Run following command on your terminal:

```sh
rails server 
```

open browser at: [http://localhost:3000](http://localhost:3000).

## Envorinment Variables

For managing google client id and secret keys I have used the dot-env gem and if you use the same, then create a .env file in your progect and add it to .gitignore file.

And create these variables in it:

```
GOOGLE_CLIENT_ID
GOOGLE_CLIENT_SECRET
CALLBACK_URL
```

## Authors

👤 **Jospin Ndaano**

- Github: [@Jospin6](https://github.com/Jospin6)
- Linkedin: [@Jospin](https://www.linkedin.com/in/jospin-ndagano-8474b7267/)

## 🤝 Contributing

Contributions, issues and feature requests are welcome!

Feel free to check the [issues page](issues/).

## Show your support

Give a ⭐️ if you like this project!

## Acknowledgments

- Hat tip to anyone whose code was used
- Inspiration

## 📝 License

This project is [MIT](lic.url) licensed

