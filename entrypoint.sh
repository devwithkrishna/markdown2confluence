#!/usr/bin/env bash

set -euo pipefail

DOCS_PATH="${MARK_DOCS_PATH:-.}"
CHANGED_ONLY="${MARK_CHANGED_ONLY:-false}"
DRY_RUN="${MARK_DRY_RUN:-false}"

EXCLUDE_DIRS="${MARK_EXCLUDE_DIRS:-}"

CONFLUENCE_URL="${MARK_URL:-}"
SPACE="${MARK_SPACE:-}"
PARENT="${MARK_PARENT:-}"

MARK_USERNAME="${MARK_USERNAME:-}"
MARK_PASSWORD="${MARK_PASSWORD:-}"

DROP_H1="${MARK_DROP_H1:-false}"
STRIP_LINEBREAKS="${MARK_STRIP_LINEBREAKS:-false}"
TITLE_FROM_H1="${MARK_TITLE_FROM_H1:-false}"
TITLE_FROM_FILENAME="${MARK_TITLE_FROM_FILENAME:-false}"



echo "========================================="
echo "DOCS_PATH           : ${DOCS_PATH}"
echo "CHANGED_ONLY        : ${CHANGED_ONLY}"
echo "DRY_RUN             : ${DRY_RUN}"
echo "EXCLUDE_DIRS        : ${EXCLUDE_DIRS:-<none>}"
echo "CONFLUENCE_URL      : ${CONFLUENCE_URL}"
echo "SPACE               : ${SPACE:-<from markdown>}"
echo "PARENT              : ${PARENT:-<from markdown>}"
echo "DROP_H1             : ${DROP_H1}"
echo "STRIP_LINEBREAKS    : ${STRIP_LINEBREAKS}"
echo "TITLE_FROM_H1       : ${TITLE_FROM_H1}"
echo "TITLE_FROM_FILENAME : ${TITLE_FROM_FILENAME}"
echo "========================================="

# Validate mark binary
if ! command -v mark >/dev/null 2>&1; then
    echo "ERROR: mark binary not found"
    exit 1
fi

# Validate required variables
required_vars=(
    MARK_PASSWORD
    CONFLUENCE_URL
    MARK_USERNAME
)

for var in "${required_vars[@]}"; do
    if [[ -z "${!var:-}" ]]; then
        echo "ERROR: Missing required variable: ${var}"
        exit 1
    fi
done

# Parse exclude directories once
declare -a EXCLUDE_ARRAY=()

if [[ -n "${EXCLUDE_DIRS}" ]]; then
    IFS=',' read -ra EXCLUDE_ARRAY <<< "${EXCLUDE_DIRS}"
fi

# Check whether a file should be excluded
should_exclude() {
    local file="$1"

    for dir in "${EXCLUDE_ARRAY[@]}"; do
        local normalized_dir="${dir#/}"
        normalized_dir="${normalized_dir%/}"

        [[ -z "${normalized_dir}" ]] && continue

        if [[ "${file}" == "${DOCS_PATH}/${normalized_dir}/"* ]]; then
            return 0
        fi
    done

    return 1
}

sync_file() {
    local file="$1"

    echo "::group::Syncing ${file}"

    # Parse metadata from HTML comments in the markdown file
    local file_space=""
    local file_parent=""
    local file_title=""
    
    if [[ -f "${file}" ]]; then
        file_space=$(sed -n 's/.*<!-- Space: \([^-]*\) -->.*/\1/p' "${file}" | head -1 || true)
        file_parent=$(sed -n 's/.*<!-- Parent: \([^-]*\) -->.*/\1/p' "${file}" | head -1 || true)
        file_title=$(sed -n 's/.*<!-- Title: \([^-]*\) -->.*/\1/p' "${file}" | head -1 || true)
    fi

    local mark_args=(
        -p "${MARK_PASSWORD}"
        -b "${CONFLUENCE_URL}"
        -u "${MARK_USERNAME}"
    )

    # Use environment variable if set, otherwise fall back to file metadata
    local space_to_use="${SPACE:-${file_space}}"
    local parent_to_use="${PARENT:-${file_parent}}"

    [[ -n "${space_to_use}" ]] && mark_args+=(--space "${space_to_use}")
    [[ -n "${parent_to_use}" ]] && mark_args+=(--parents "${parent_to_use}")
    [[ "${DRY_RUN}" == "true" ]] && mark_args+=(--dry-run)

    # Formatting options
    [[ "${DROP_H1}" == "true" ]] && mark_args+=(--drop-h1)
    [[ "${STRIP_LINEBREAKS}" == "true" ]] && mark_args+=(-L)
    [[ "${TITLE_FROM_H1}" == "true" ]] && mark_args+=(--title-from-h1)
    [[ "${TITLE_FROM_FILENAME}" == "true" ]] && mark_args+=(--title-from-filename)

    echo "Running: mark ${file}"
    
    local retries=3
    local attempt=1

    until mark "${mark_args[@]}" -f "${file}"; do
        if [[ "${attempt}" -ge "${retries}" ]]; then
            echo "ERROR: Failed syncing ${file} after ${retries} attempts"
            echo "::endgroup::"
            return 1
        fi

        echo "Retry ${attempt}/${retries} failed. Retrying in 5 seconds..."
        sleep 5
        ((attempt++))
    done

    echo "::endgroup::"
}

build_find_command() {
    local -a cmd=(
        find
        "${DOCS_PATH}"
        -type f
        -name "*.md"
    )

    for dir in "${EXCLUDE_ARRAY[@]}"; do
        local normalized_dir="${dir#/}"
        normalized_dir="${normalized_dir%/}"

        [[ -z "${normalized_dir}" ]] && continue

        cmd+=(
            -not
            -path
            "${DOCS_PATH}/${normalized_dir}/*"
        )
    done

    "${cmd[@]}"
}

get_changed_files() {
    # Handle shallow clone / first commit gracefully
    if git rev-parse HEAD~1 >/dev/null 2>&1; then
        git diff --name-only HEAD~1 HEAD
    else
        git ls-files '*.md'
    fi | grep '\.md$' || true
}

echo "Discovering markdown files..."

if [[ "${CHANGED_ONLY}" == "true" ]]; then
    echo "Running in changed-only mode"

    FILES="$(
        while IFS= read -r file; do
            [[ -z "${file}" ]] && continue

            # Skip deleted files
            [[ ! -f "${file}" ]] && continue

            if ! should_exclude "${file}"; then
                echo "${file}"
            fi
        done <<< "$(get_changed_files)"
    )"
else
    FILES="$(build_find_command)"
fi

if [[ -z "${FILES}" ]]; then
    echo "No markdown files found"
    exit 0
fi

echo "Files to sync:"
echo "${FILES}"
echo "========================================="

while IFS= read -r file; do
    [[ -z "${file}" ]] && continue
    sync_file "${file}"
done <<< "${FILES}"

echo "Sync completed successfully"