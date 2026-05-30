# markdown2confluence

<!-- Space: devwithkrishna -->
<!-- Parent: GitHub -->

<!-- Macro: :toc:
     Template: ac:toc
     Printable: 'false'
     MinLevel: 2 -->


Sync your markdown documentation with Atlassian Confluence pages

<!-- Include: docs/warning.tpl -->

:toc:

<!-- action-docs-all source="action.yml" project="devwithkrishna/markdown2confluence" version="latest" -->
## Description

Sync markdown docs to Confluence using mark

## Inputs

| name | description | required | default |
| --- | --- | --- | --- |
| `username` | <p>The username used to authenticate with Confluence</p> | `false` | `""` |
| `password` | <p>The token to be used to authenticate with Confluence</p> | `true` | `""` |
| `docs-path` | <p>Folder containing markdown files</p> | `false` | `.` |
| `exclude-dir` | <p>Exclude the markdown files inside this path</p> | `false` | `""` |
| `changed-only` | <p>Sync only changed markdown files</p> | `false` | `false` |
| `dry-run` | <p>If true this will not push any changes, but to log the change it would have made</p> | `false` | `false` |
| `confluence-url` | <p>The destination Confluence url</p> | `true` | `""` |
| `space` | <p>Specific Confluence space to publish to</p> | `false` | `""` |
| `parent` | <p>Specific Confluence parent to publish to</p> | `false` | `""` |
| `drop-h1` | <p>Don't include the first H1 heading in Confluence output</p> | `false` | `false` |
| `strip-linebreaks` | <p>Remove linebreaks inside of tags, to accommodate non-standard Confluence behavior</p> | `false` | `false` |
| `title-from-h1` | <p>Extract page title from a leading H1 heading. If no H1 heading on a page exists, then title must be set in the page metadata</p> | `false` | `false` |
| `title-from-filename` | <p>Use the filename (without extension) as the Confluence page title if no explicit page title is set in the metadata</p> | `false` | `false` |
| `log-level` | <p>set the log level. Possible values: TRACE, DEBUG, INFO, WARNING, ERROR, FATAL. (default: 'info')</p> | `false` | `info` |


## Runs

This action is a `docker` action.

## Usage

```yaml
- uses: devwithkrishna/markdown2confluence@latest
  with:
    username:
    # The username used to authenticate with Confluence
    #
    # Required: false
    # Default: ""

    password:
    # The token to be used to authenticate with Confluence
    #
    # Required: true
    # Default: ""

    docs-path:
    # Folder containing markdown files
    #
    # Required: false
    # Default: .

    exclude-dir:
    # Exclude the markdown files inside this path
    #
    # Required: false
    # Default: ""

    changed-only:
    # Sync only changed markdown files
    #
    # Required: false
    # Default: false

    dry-run:
    # If true this will not push any changes, but to log the change it would have made
    #
    # Required: false
    # Default: false

    confluence-url:
    # The destination Confluence url
    #
    # Required: true
    # Default: ""

    space:
    # Specific Confluence space to publish to
    #
    # Required: false
    # Default: ""

    parent:
    # Specific Confluence parent to publish to
    #
    # Required: false
    # Default: ""

    drop-h1:
    # Don't include the first H1 heading in Confluence output
    #
    # Required: false
    # Default: false

    strip-linebreaks:
    # Remove linebreaks inside of tags, to accommodate non-standard Confluence behavior
    #
    # Required: false
    # Default: false

    title-from-h1:
    # Extract page title from a leading H1 heading. If no H1 heading on a page exists, then title must be set in the page metadata
    #
    # Required: false
    # Default: false

    title-from-filename:
    # Use the filename (without extension) as the Confluence page title if no explicit page title is set in the metadata
    #
    # Required: false
    # Default: false

    log-level:
    # set the log level. Possible values: TRACE, DEBUG, INFO, WARNING, ERROR, FATAL. (default: 'info')
    #
    # Required: false
    # Default: info
```
<!-- action-docs-all source="action.yml" project="devwithkrishna/markdown2confluence" version="latest" -->


<!-- Include: docs/footer.tpl -->