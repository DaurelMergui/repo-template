# Security policy

## Reporting a vulnerability

Please report security problems privately through GitHub's
[private vulnerability reporting](https://github.com/DaurelMergui/repo-template/security/advisories/new)
for this repository. Do not open a public issue for a vulnerability.

You can expect an acknowledgement within a week. This is a personal project maintained by one person,
so there is no guaranteed fix time, but confirmed issues in the template's workflows, scripts or
Dockerfiles are fixed in the next release and noted in its release notes.

## Supported versions

Only the latest release is supported. Repositories created from the template should run the drift
check (`scripts/sync-from-template.sh`) to stay current.

## Scope

In scope: the shipped workflows, scripts, Dockerfiles and the pinned tool versions in them.
Out of scope: vulnerabilities in third-party tools and base images themselves (report those upstream).
