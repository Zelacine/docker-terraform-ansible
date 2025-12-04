# sysadmin-infra-homework


# Running Docker for Nginx + PHP-FPM, Terraform, Ansible on localhost

This repository is a **template** for completing the test assignment. Full description is in [INSTRUCTIONS.md](./INSTRUCTIONS.md).

## What's already included
- Directory structure for Terraform/Ansible.
- Basic GitHub Actions workflows: `terraform.yml`, `ansible.yml`.
- Template files for `web` role (Ansible) and minimal Terraform configs.

## What the candidate needs to implement (briefly)
1. **Terraform**: describe `nginx` and `php-fpm` containers (docker provider), network and volume, variables and outputs.
2. **Ansible**: `web` role should deploy Nginx config, index.php, enable `nginx` and `php-fpm`, add logrotate.
3. Clean up and complete workflows (fmt/validate/plan + ansible-lint), optionally add Molecule tests for the role.
4. **README**: complete the steps below for running and testing (see "Local Run" section).

---

## Local Run

Your change in ansible: roles/web/defaults/main.yml 
should have the same name as in terraform.tvars
example:
```
terraform: terraform.tfvars
project_name = "php-app-my"
ansible roles/web/defaults/main.yml 
web_project_name: php-app-my
```
### Start terraform 

```
# example
cd /terraform
terraform init
terraform fmt -check
terraform validate
terraform plan 
terraform apply -auto-approve
```
#### Outputs:
```
# example
app_url = "http://localhost:8080/"
healthz_url = "http://localhost:8080/healthz"
network_name = "php-app-my-network"
nginx_container_name = "php-app-my-nginx"
php_fpm_container_name = "php-app-my-php-fpm"
volume_name = "php-app-my-volume"
```


### Start ansible

```
cd /ansible
```
**Missing Docker modules**
 'community.docker.docker_container_copy' and the other Docker modules come from the 'community.docker' collection. Install it once on your control machine:
```bash   
   ansible-galaxy collection install community.docker
```    
Add a tiny inventory and point the playbook at it, e.g. create ansible/inventory containing:
```bash
   [local]
   localhost ansible_connection=local
```
Then run syntax check ansible playbook:
```bash
   ansible-playbook -i inventory --syntax-check playbook.yml
```
Validation ansible lint:
```bash
   ansible-lint playbook.yml
# example out
Passed: 0 failure(s), 0 warning(s) on 4 files. Last profile that met the validation criteria was 'production'.

```  
   
(No sudo needed unless your Ansible is installed system wide.) If you prefer project-local collections, run that command inside the project and set `ANSIBLE_COLLECTIONS_PATHS` or add to `ansible.cfg`.

Run ansible-playbook:
```bash
   ansible-playbook -i inventory  playbook.yml
```



### Status Check
```
curl http://localhost:8080/healthz
# expected JSON:
# {"status":"ok","service":"nginx","env":"dev"}
```
### Staus Check php-fpm service
```
http://localhost:8080/healthz-php
# expected JSON:
# {"status":"ok","service":"php-fpm","env":"dev","php_version":"8.2.29","timestamp":"2025-11-25T08:29:30+00:00"}
```

## CI/CD
- **Actions** tab should be green: Terraform (fmt/validate/plan) and ansible-lint pass.
- Attach screenshots or links to successful runs:




[32]

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


