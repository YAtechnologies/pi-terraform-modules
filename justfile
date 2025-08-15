set shell := ["bash", "-uc"]

[private]
@default:
  just --list

# run pre-commit checks
[group('lint')]
pre-commit:
    pre-commit run --all-files

[no-cd]
validate:
    pwd
    terraform init -backend=false
    terraform validate 