robot.timecards
===============

A robot which sends SMS to remind people who forget to submit last week's timecards.

## Setup

```bash
    $ bin/setup.sh
```

## Configuration

1. Configure email address and password in file `lib/config.rb`.
2. Configure SMS signature in file `lib/config.rb`.
3. Configure admins in `data/admins.csv` in the following format:

    ```
    username@thoughtworks.com,13900000000
    username@thoughtworks.com,13900000000
    ```

4. Configure API key or username and password for SMS services in `lib/sms_services/*.rb`.

## Get contacts

1. Export consultants.csv from Jigsaw.
2. `$ ruby sync_contacts.rb`
3. `$ ruby split_contacts.rb`

## Testing

Just send a email with subject:"This is a test email" to robot's email, later, admins should receive a SMS about that email.

