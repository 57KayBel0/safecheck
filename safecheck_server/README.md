# safecheck_server

This is the starting point for your Serverpod server.

Start your server by running:

    cd safecheck
    serverpod start

When you are finished, you can shut down the running server with `Q`.

## BulkSMS development setup

SafeCheck uses the demo sender by default. Configuring API credentials alone
does not enable live delivery. The server reads `bulkSmsTokenId`,
`bulkSmsTokenSecret`, and the explicit `bulkSmsMode: live` setting from the
active Serverpod password section. Keep these values private and never commit
`config/passwords.yaml`.

Add the three entries under the existing `development:` mapping in
`config/passwords.yaml`. Keep the existing `googleClientSecret` entry in that
same mapping; add these sibling keys without replacing it:

```yaml
development:
  # Keep the existing database, JWT, email, and googleClientSecret entries.
  bulkSmsMode: live
  bulkSmsTokenId: "<your BulkSMS API Token ID>"
  bulkSmsTokenSecret: "<your BulkSMS API Token Secret>"
```

The values in angle brackets are instructions, not valid YAML credentials.
Do not add placeholders or dummy values to the active password file. Omit
`bulkSmsMode` or set it to `demo` to keep all messages simulated. The server
must be restarted after changing the mode or credentials.

BulkSMS `sent` means its API accepted the submission; SafeCheck does not mark
it `delivered` unless the provider response explicitly confirms delivery. This
prototype does not yet receive asynchronous BulkSMS delivery reports.

To send one controlled live test to yourself, add only your own phone as an
SMS-enabled trusted contact (or turn off SMS for every other contact), then
start the trip so that its contact snapshot contains only your number. Set the
development mode to `live`, restart the server, start a short trip, and let it
miss its deadline. That creates one real SMS submission to your number. Return
the mode to `demo` and restart immediately afterward. Do not test with an
existing trip: recipients are snapshotted when a trip starts.
