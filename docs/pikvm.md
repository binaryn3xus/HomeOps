# PiKVM

## Update PiKVM

To update, run following commands under the `root` user:

```sh
pikvm-update
```

If for some reason that command does not work, try this one...

```sh
curl https://files.pikvm.org/update-os.sh | bash
```

## Load TESmart KVM

1. Enter Read/Write Mode

    ```sh
    rw
    ```

2. Add or replace the file `/etc/kvmd/override.yaml`

    See repo's [override.yaml](./pikvm/override.yaml)
    

3. Restart kvmd
    ```sh
    systemctl restart kvmd.service
    ```

