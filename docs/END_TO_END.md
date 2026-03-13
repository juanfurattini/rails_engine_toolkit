# End-to-end smoke test

A lightweight host app fixture is included under `test/fixtures/host_app`.

## Typical smoke workflow

From a temporary Rails app or the fixture app:

```bash
bundle install
bin/rails generate engine_toolkit:install
bundle exec engine-toolkit new_engine auth
bundle exec engine-toolkit new_engine_model auth credential email:string
bundle exec engine-toolkit install_engine_migrations auth
bin/rails db:migrate
```

## Migration uninstall note

If you later run:

```bash
bundle exec engine-toolkit uninstall_engine_migrations auth
```

the toolkit removes copied files from `db/migrate`, but it does **not** rollback the database automatically. Run your down/rollback flow manually first if needed.
