# demo-pipeline
Demo a full pipeline: code to cloud with Scribe instrumentation and uploading of evidence

To try it out:
1. Scribe will set up a fork of this repo with appropreiate secrets set.
2. Scribe shall walk you through running the workflows and understanding the results.


The code includes:
- A `package.json` file with a `start` script that imports a KEV vulnerable module [CVE-2021-21315](https://nvd.nist.gov/vuln/detail/CVE-2021-21315) 
- A python script with a secret in the code

- The `on-push.yml` workflow create two reference SBOMs: one for the git-commit, and one for comparing dependencies.
- The build2gcr.yml builds the image and create a file-level sbom to enable (among other features) also verifying dependencies integrity. 

Example:
* build2gcr sbom ref: 332448 (Gold Team)
* on-push sbom ref: 332452 (Gold Team)

Goto to Analytics->fileDiff, enter these two attestation ids and enter a file path regex such as /app/node_modules/* 
Expect to get empty results as the dependencies are the same in both the SBOMs.

