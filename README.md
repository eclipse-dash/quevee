
# QUality EVEnt Engine (quevee) github action

This action creates a `sdv-manifest.toml` file as a release asset, containing information required for the [SDV Maturity assessment](https://gitlab.eclipse.org/eclipse-wg/sdv-wg/sdv-technical-alignment/sdv-technical-topics/sdv-process/sdv-process-evaluation/-/blob/main/README.md) program. It takes as inputs a set of documents provided by the project, and formats it in a way that Eclipse SDV automation scripts can use to compute the level of maturity of the project according to the criteria defined in the program.


## Usage

To use this action, one simply needs to add the following steps in their release action workflow:

```yaml
      # Call the quevee gh action to create the manifest file for SDV maturity assessment.
      - name: Collect quality artefacts
        uses: eclipse-dash/quevee
        id: quevee
        with:
          release_url: ${{ steps.create_release.outputs.url }}
          artefacts_requirements: <path/to/requirements_file>
          artefacts_testing: <path/to/testing_document>
          artefacts_documentation: <path/to/documentation>
          artefacts_coding_guidelines: <path/to/coding_guidelines>
          artefacts_release_process: <path/to/release_process>
      - name: Upload quality manifest to release
        uses: svenstaro/upload-release-action@v2
        with:
          repo_token: ${{ secrets.GITHUB_TOKEN }}
          file: ${{ steps.quevee.outputs.manifest_file }}
          tag: ${{ github.ref }}

```

The various <path/to/file> placeholders can either be:
* a path to the file within the repository, e.g. `docs/getting_started.md`, or
* a full URL to a resource, e.g. `https://myproject/docs/getting_started.pdf`.

A more complete example can be found in the GitHub workflow of this repository: [.github/workflows/release.yml](.github/workflows/release.yml).

## Output

The action creates a file called `sdv-manifest.toml` as an asset of the release. Its content is as follows:

```toml
repo-url = "https://github.com/borisbaldassari/quevee-test"
created = "Thu May 15 16:06:27 UTC 2025"
by-action = "quevee"
project = "borisbaldassari"
repository = "quevee-test"
ref-tag = "v0.0.9"
git-hash = "4ef764b812cf55e129408bfac792e16d8b5754b3"
release-url = "https://github.com/borisbaldassari/quevee-test/releases/tag/v0.0.9"

requirements = [
    "https://raw.githubusercontent.com/borisbaldassari/quevee-test/4ef764b812cf55e129408bfac792e16d8b5754b3/docs/requirements.md",
]

coding_guidelines = [
    "https://raw.githubusercontent.com/borisbaldassari/quevee-test/4ef764b812cf55e129408bfac792e16d8b5754b3/docs/coding_guidelines.md",
]

documentation = [
    "https://raw.githubusercontent.com/borisbaldassari/quevee-test/4ef764b812cf55e129408bfac792e16d8b5754b3/docs/getting_started/",
]

release_process = [
    "https://example.org/my_release_process/",
    ]

testing = [
    "https://raw.githubusercontent.com/borisbaldassari/quevee-test/4ef764b812cf55e129408bfac792e16d8b5754b3/tests/",
    ]
```

