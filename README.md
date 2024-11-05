# QUality EVEnt Engine (quevee) github action

This action accepts a set of input URLs pointing to release artifacts of various categories (like 'documentation' or 'testing'), and creates a toml file that contains project and release metadata as well as the artifact URLs. The goal is to document release artifacts that are relevant for assessment of project quality aspects, and present them for evaluation and archival in quality assessment processes.

## Inputs

### `release_url`

URL of the release this manifest refers to.

### `artifacts_documentation`

Comma-separated list of URLs of documentation artifacts.

### `artifacts_licensing`

Comma-separated list of URLs of licensing information.

### `artifacts_readme`

Comma-separated list of URLs of readme files.

### `artifacts_requirements`

Comma-separated list of URLs of requirement files.

### `artifacts_testing`

Comma-separated list of URLs of test results.

## Outputs

### `manifest_file`

Process artifacts manifest file name.

## Simple example

Conceptually, this is how quevee is used:

```yaml
- name: Collect quality artifacts
  uses: anotherdaniel/quevee@v0.1
  with:
    artifacts_readme: <readme-url>
    artifacts_requirements: <req-url1>,<req-url2>
```

This invocation will generate the following manifest structure:

```toml
[metadata]
<repository and release-specific information>

readme = [
    "readme-url",
]

requirements = [
    "req-url1", 
    "req-url2",
]
```

## Realistic example

A more complete example, applied to the quevee repository:

```yaml
jobs:
  quality_artifacts_job:
    name: A job to collect quality artifacts
    runs-on: ubuntu-latest
    permissions: write-all
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Create release
        uses: softprops/action-gh-release@v2
        id: create_release
      - name: Show release URL
        run: |
          echo ${{ steps.create_release.outputs.url }}

      # Upload artifacts to release
      - name: Upload README to release
        uses: svenstaro/upload-release-action@v2
        id: upload_readme
        with:
          repo_token: ${{ secrets.GITHUB_TOKEN }}
          file: README.md
          tag: ${{ github.ref }}
      - name: Upload LICENSE to release
        uses: svenstaro/upload-release-action@v2
        id: upload_license
        with:
          repo_token: ${{ secrets.GITHUB_TOKEN }}
          file: LICENSE
          tag: ${{ github.ref }}

      # Collection quality artifacts
      - name: Collect quality artifacts
        uses: anotherdaniel/quevee@v0.1
        id: quevee
        with:
          release_url: ${{ steps.create_release.outputs.url }}
          artifacts_readme: ${{ steps.upload_readme.outputs.browser_download_url }}
          artifacts_requirements: ${{ steps.upload_license.outputs.browser_download_url }},https://yet.another.org/example/artifact.bz2
      - name: Upload quality manifest to release
        uses: svenstaro/upload-release-action@v2
        id: upload_manifest
        with:
          repo_token: ${{ secrets.GITHUB_TOKEN }}
          file: ${{ steps.quevee.outputs.manifest_file }}
          tag: ${{ github.ref }}
      - name: Store quality manifest as workflow artifact
        uses: actions/upload-artifact@v4
        id: store_manifest
        with:
          name: quality-artifacts-manifest
          path: ${{ steps.quevee.outputs.manifest_file }}
````

This invocation will generate the following manifest structure (test run on the quevee repository):

```toml
[metadata]
repo-url = "https://github.com/AnotherDaniel/quevee"
created = "Sat Mar  9 18:20:29 UTC 2024"
by-action = "quevee"
project = "AnotherDaniel"
repository = "quevee"
ref-tag = "v0.1.20"
git-hash = "22a0af5f8acb723801c85d5a8871019f5ff6f7ec"
release-url = "https://github.com/AnotherDaniel/quevee/releases/tag/v0.1.20"

requirements = [
    "https://github.com/AnotherDaniel/quevee/releases/download/v0.1.20/LICENSE",
    "https://yet.another.org/example/artifact.bz2",
]

readme = [
    "https://github.com/AnotherDaniel/quevee/releases/download/v0.1.20/README.md",
]    
```
