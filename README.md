# ansible-winpe

Ansible playbooks and role automation to build customized WinPE ISO images on a Windows builder host.

## What this repo does

- Provisions a Windows ADK build node (VMware or KubeVirt flows available)
- Installs ADK + WinPE addon
- Injects bootstrap scripts, curl, and optional drivers/modules into `boot.wim`
- Produces both standard and `_no_prompt` WinPE ISO outputs

Primary playbooks:

- `generate_winpe.yml` (generate on existing builder host)
- `generate_winpe_stack_full_vmware.yml` (provision infra + generate)

## Provisioning server modes

The role supports two provisioning server patterns, controlled by:

- `winpe_provisioning_server_type`
	- `foreman` (default)
	- `cobbler`

### Foreman mode (default)

- Uses `init_foreman.cmd` + `setsysname_foreman.cmd`
- Downloads `unattend.xml` from Foreman at `/unattended/provision`
- Downloads rendered `mountmedia.cmd` from Foreman at `/unattended/script`
- Starts setup with `setup.exe /unattend:<file>`
- Posts `/unattended/built?token=...` from WinPE after `setup.exe` returns
	(token is injected by rendered `mountmedia.cmd`)

Important Foreman requirement:

- WinPE boots without a template token, so Foreman must allow provisioning template access by build host/IP.
- In practice, disable token requirement for templates (or otherwise allow IP-matched access for unattended provisioning).

### Cobbler mode

- Uses existing Cobbler flow (`init.cmd` + `setsysname.cmd`)
- Resolves host identity through Cobbler APIs and fetches dynamic scripts

## Key variables

Defaults live in `roles/winpe/defaults/main.yml`.

Core output/control:

- `winpe_arch`
- `winpe_os_level` (`win_10`, `win_11`, `win_2022`)
- `winpe_smb_share`
- `winpe_destination_file_location`
- `winpe_enable_script_debug`
- `winpe_enable_powershell_modules`

Provisioning mode gate:

- `winpe_provisioning_server_type: foreman`

Foreman-specific:

- `winpe_foreman_host`
- `winpe_foreman_port`
- `winpe_foreman_scheme`
- `winpe_foreman_setupcomplete_in_winpe`
- `winpe_foreman_built_callback_retries`
- `winpe_foreman_built_callback_retry_delay_sec`

Cobbler-specific:

- `winpe_cobbler_host`
- `winpe_cobbler_port`

## Example variable blocks

### Foreman (recommended/default)

```yaml
winpe_provisioning_server_type: foreman
winpe_foreman_host: foreman.example.com
winpe_foreman_port: 443
winpe_foreman_scheme: https
winpe_foreman_setupcomplete_in_winpe: true
winpe_foreman_built_callback_retries: 10
winpe_foreman_built_callback_retry_delay_sec: 15

winpe_smb_share: \\\\fileserver\\isos
winpe_destination_file_location: winpe
winpe_arch: amd64
winpe_os_level: win_2022
```

### Cobbler

```yaml
winpe_provisioning_server_type: cobbler
winpe_cobbler_host: cobbler.example.com
winpe_cobbler_port: 8080

winpe_smb_share: \\\\fileserver\\isos
winpe_destination_file_location: winpe
winpe_arch: amd64
winpe_os_level: win_2022
```

## Running

1. Ensure your inventory targets hosts matching `*_role_wadk` (used by `generate_winpe.yml`).
2. Provide credentials/env vars as needed:
	 - `SMB_SHARE_USERNAME`
	 - `SMB_SHARE_PASSWORD`
	 - `FOREMAN_HOST` (if not set directly in vars)
	 - `COBBLER_host` (for Cobbler mode)
3. Run:

```bash
ansible-playbook generate_winpe.yml -i <inventory>
```

For full VMware stack provisioning + WinPE generation:

```bash
ansible-playbook generate_winpe_stack_full_vmware.yml -i <inventory>
```

## Output naming

- Cobbler mode base: `winpe_<cobbler_host>_<arch>`
- Foreman mode base: `winpe_<foreman_host>_<arch>_no_prompt`

Both standard and `_no_prompt` ISO artifacts are produced and copied to `winpe_smb_share` / `winpe_destination_file_location`.
