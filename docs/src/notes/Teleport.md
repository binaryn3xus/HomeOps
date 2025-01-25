# Teleport Notes

## Getting Started

This starts after you have it setup and running in your cluster. This is the setup process that i used.

### Setup a local user

```sh
kubectl exec -i deployment/teleport-auth -n teleport -- tctl users add <USERNAME> --roles=editor,access --logins=root
```
* Replace `<USERNAME>` with whatever local username you want to use.

Follow the wizard to setup this account.

### Setting up Github SSO

Offical Docs: [Set up Single Sign-On with GitHub](https://goteleport.com/docs/access-controls/sso/github-sso/)

1. Go into the Teleport Management Screen and click on Auth Connectors
2. Create a new Github Connector
3. Edit to setup your github org information and secrets

Example:
```yaml
version: v3
kind: github
metadata:
  name: new_github_connector
spec:
  api_endpoint_url: ""
  client_id: <your-github-org-client-id>
  client_secret: <your-github-org-secret>
  display: GitHub
  endpoint_url: ""
  redirect_url: https://teleport.EXAMPLE.com/v1/webapi/github/callback
  teams_to_logins: null
  teams_to_roles:
  - organization: <ORG_NAME>
    roles:
    - access
    - editor
    team: <ORG_TEAM>
```

> Note: Please make sure you set your roles and secrets accordingly. You can get the information from your organizations settings > Developer Settings section.

### Add custom users to a role

For this, I needed to add custom login ids for certain SSH instances. So for this, go to the role you want to edit in the management screen.

Add the logins you want to add under the following section: `.spec.allow.logins`.

For Example:

```yaml
    logins:
    - '{{internal.logins}}'
    - janedoe
    - johndoe
```

Save and you may want to log out and back in. This may not be required but doesnt hurt.

## Cluster Commands

Most commands that start with `kubectl exec -i deployment/teleport-auth -n teleport -- ` are run from a terminal that has access to the Cluster using kubectl.

### Check inventory

```bash
kubectl exec -i deployment/teleport-auth -n teleport -- tctl inventory status --connected
```

### List Server Nodes

```bash
kubectl exec -i deployment/teleport-auth -n teleport -- tctl nodes ls
```

### CLI Remove/Disconnect Teleport on Nodes/Servers

```bash
sudo pkill -f teleport && \
sudo rm -rf /var/lib/teleport && \
sudo rm -f /etc/teleport.yaml && \
sudo rm -f /usr/local/bin/teleport /usr/local/bin/tctl /usr/local/bin/tsh && \
sudo apt remove teleport -y
```

### Setup Kubernetes Tokens via Service Account

[Docs - Joining Services via Kubernetes ServiceAccount Token](https://goteleport.com/docs/agents/join-services-to-your-cluster/kubernetes/)

`kubectl exec -i <teleport-auth-... pod name> -n teleport -- tctl create -f - < ./kubernetes/apps/teleport/teleport/app/resources/token.yaml`
