# Managing Emails

When we complete a build for any branch that isn't starred, by default we'll send an email to the address associated with the author of the most recent commit.

```
commit 7871d26076e1f79fe41a58c57a121d418a57b2d0
Author: Keith Pitt <me@keithpitt.com>
```

This means we'll be sending emails to the address you have configured in git. You can see this address using the following command: `git config --get user.email`

If this is your personal email and your committing to a work pipeline, you might prefer that those notifications get sent to your work email address.

Setting it up is easy. The first thing you'll want to do is let us know about your work and personal emails by adding them to your account: <%= url_helpers.user_emails_url %>

<%= image("create-emails.png") %>

Once you have registered your work and personal emails you can then configure which email address your notifications should go to.

<%= image("connect-to-accounts.png") %>
