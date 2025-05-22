
# QUality EVEnt Engine (quevee) github action

This action creates a `sdv-manifest.toml` file as a release asset, containing information required for the [SDV Maturity assessment](https://gitlab.eclipse.org/eclipse-wg/sdv-wg/sdv-technical-alignment/sdv-technical-topics/sdv-process/sdv-process-evaluation/-/blob/main/README.md) program. It takes as inputs a set of documents provided by the project, and formats it in a way that Eclipse SDV automation scripts can use to compute the level of maturity of the project according to the criteria defined in the program.


## Usage

To use this action, one simply needs to add the following steps in their release action workflow:

```yaml
      # Call the quevee gh action to create the manifest file for SDV maturity assessment.
      - name: Collect quality artifacts
        uses: eclipse-dash/quevee@v1
        id: quevee
        with:
          release_url: ${{ steps.create_release.outputs.url }}
          artifacts_requirements: <path/to/requirements_file>
          artifacts_testing: <path/to/testing_document_1>,<path/to/testing_document_2> 
          artifacts_documentation: <path/to/documentation>
          artifacts_coding_guidelines: <path/to/coding_guidelines>
          artifacts_release_process: <path/to/release_process>
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

If one needs to provide several files for a given criterion, there are two options:
* provide a comma-separated list of files, as shown for the artifacts_testing example above, or
* provide an archive, with a separate github action step.

An example of a step archiving artifacts can be:
```yaml
      - name: Gather Testing documents
        shell: bash
        run: |
          tar cvz --file spec.tar.gz /path/to/dir
      - name: Upload relevant spec files to release
        uses: svenstaro/upload-release-action@v2
        id: upload_spec
        with:
          repo_token: ${{ secrets.GITHUB_TOKEN }}
          file: spec.tar.gz
          tag: ${{ github.ref }}
```

This in turn can be referenced in the quevee call as:
```yaml
          ...
          artifacts_testing: ${{ steps.upload_spec.outputs.browser_download_url }}
          ...
```

A more complete example can be found in the GitHub workflow of this repository: [.github/workflows/release.yml](.github/workflows/release.yml).

## Output

The action creates a file called `sdv-manifest.toml` as an asset of the release. Its content is as follows:

```toml
repo-url = "https://github.com/borisbaldassari/quevee-test"
created = "Thu May 15 16:06:27 UTC 2025"
by-action = "quevee"
project = "borisbaldassari"
repository = "quevee-test"
ref-tag = "v0.1.3"
git-hash = "657a397af6f8e5249a519b5d63a5b8f64e763b29"
release-url = "https://github.com/borisbaldassari/quevee-test/releases/tag/v0.1.3"

requirements = [
    "https://raw.githubusercontent.com/borisbaldassari/quevee-test/657a397af6f8e5249a519b5d63a5b8f64e763b29/docs/requirements.md",
]

coding_guidelines = [
    "https://raw.githubusercontent.com/borisbaldassari/quevee-test/657a397af6f8e5249a519b5d63a5b8f64e763b29/docs/coding_guidelines.md",
]

documentation = [
    "https://raw.githubusercontent.com/borisbaldassari/quevee-test/657a397af6f8e5249a519b5d63a5b8f64e763b29/docs/getting_started/",
]

readme = [
    "https://raw.githubusercontent.com/borisbaldassari/quevee-test/657a397af6f8e5249a519b5d63a5b8f64e763b29/README.md",
]

release_process = [
    "https://example.org/my_release_process/",
    ]

testing = [
    "https://raw.githubusercontent.com/borisbaldassari/quevee-test/657a397af6f8e5249a519b5d63a5b8f64e763b29/tests/file_1",
    "https://raw.githubusercontent.com/borisbaldassari/quevee-test/657a397af6f8e5249a519b5d63a5b8f64e763b29/tests/file_2",
]
```

