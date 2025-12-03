# sysadmin-infra-homework



[32 tools called]

## Containers via Terraform, Config via Ansible
- `terraform/main.tf` and `terraform/modules/nginx-container/*` no longer mount host config files; Terraform now just provisions the Docker network, shared volume, and nginx/php-fpm containers. The old `terraform/nginx.conf` file was removed.
- Run `terraform fmt` locally (Terraform isn’t installed in this shell) and re-run `terraform plan` to refresh the plan artifact.

## Ansible role updates
- `ansible/roles/web/defaults/main.yml` gained a `web_nginx_temp_conf_path`, PHP-FPM pool settings (`web_php_pm`, `*_children`, `*_servers`, etc.), and staging paths for pushing configs into containers.
- `ansible/roles/web/tasks/main.yml` now copies the nginx config, logrotate file, PHP index/health scripts, and the new PHP-FPM pool config directly into the running containers using `docker cp` + `cat ... > dest`. Idempotence is preserved because each command runs on every play but only reports `changed` when the source template changed.
- New template `ansible/roles/web/templates/php-fpm-pool.conf.j2` lets you switch between `dynamic` and `static` pools simply by setting `web_php_pm` (plus the related sizing variables). The pool template injects `APP_ENV`, exposes the optional status path, and writes to `/usr/local/etc/php-fpm.d/www.conf`.
- `healthz.php` is already templated and copied; nginx now proxies `/healthz-php` through PHP-FPM so you have both a lightweight nginx probe and a full-stack probe.

### Choosing static vs dynamic pools
In playbooks/inventory you can now set, e.g.:

```yaml
web_php_pm: static
web_php_pm_max_children: 20
```

or rely on the defaults for dynamic mode (`pm.start_servers`, `pm.min_spare_servers`, etc.). The molecule verify playbook now asserts that the pool file contains the requested mode and `env[APP_ENV]`.

## Molecule scenario
`molecule/default/{converge,verify}.yml` were refreshed:
- Converge spins up bare nginx/php-fpm containers (no host config volume) so the role exercises the same copy logic you’ll use in production.
- Verify checks nginx health endpoints inside the container, confirms files exist inside php-fpm, hits `/healthz` and `/healthz-php`, and inspects the PHP-FPM pool config.

## Follow-up / Manual steps
1. Run `terraform fmt` and `terraform plan` locally (Terraform binary isn’t present here).
2. Re-run `ansible-lint` / Molecule if you use them (`ansible-galaxy collection install community.docker` first).
3. Apply Terraform, then run `ansible-playbook ansible/playbook.yml` with the desired `web_php_pm` settings to push configs.

That separation now matches your requirement: Terraform “lifts” the containers/network/volume, while Ansible owns all configuration, including the new PHP-FPM static/dynamic pool control.