#!/bin/bash

export GIT_PAGER=''
# Function to get the last tag with a specific prefix
get_last_tag_with() {
    local prefix="$1"
    local is_required="$2"

    echo "DEBUG: Looking for prefix: ${prefix}*" >&2

    # Показываем все доступные теги для отладки
    echo "Available tags:" >&2
    git tag -l >&2

    local tag
    tag=$(git tag -l "${prefix}*" | sort -V | tail -n1)
    local git_result=$?

    echo "DEBUG: git command result: $git_result" >&2
    echo "DEBUG: found tag: $tag" >&2

    if [ -n "$tag" ]; then
        echo "Found tag: $tag" >&2
        echo "$tag"
        return 0
    else
        echo "No tags found matching pattern: ${prefix}*" >&2
        if [ "$is_required" = "REQUIRED" ]; then
            return 1
        else
            return 0
        fi
    fi
}

# Function to count commits from tag to HEAD
count_commits_from_tag() {
    local tag="$1"
    local count

    count=$(git rev-list "$tag"..HEAD --count 2>/dev/null)
    if [ $? -eq 0 ]; then
        echo "$count"
        return 0
    else
        echo "Error counting commits from $tag to HEAD" >&2
        return 1
    fi
}

# Function to parse version from tag
parse_version_from_tag() {
    local input="$1"
    local prefix="$2"
    local delimiter="$3"

    # Remove prefix from tag
    local version_str=${input#"$prefix"}

    echo "DEBUG: version string after prefix removal: $version_str" >&2

    # Split version into array
    IFS="$delimiter" read -ra version_parts <<< "$version_str"

    # Get commit count for tweak version
    local commit_count
    commit_count=$(count_commits_from_tag "$input")
    commit_count=${commit_count:-0}

    # Set default values
    local major=${version_parts[0]:-0}
    local minor=${version_parts[1]:-0}
    local patch=${version_parts[2]:-0}
    local tweak

    # Calculate tweak version
    if [ ${#version_parts[@]} -ge 4 ]; then
        tweak=$((commit_count + ${version_parts[3]}))
    else
        tweak=$commit_count
    fi

    # Output version components
    if [ -n "$major" ] && [ -n "$minor" ] && [ -n "$patch" ]; then
        echo "MAJOR=$major"
        echo "MINOR=$minor"
        echo "PATCH=$patch"
        echo "TWEAK=$tweak"
    else
        return 1
    fi
}

# Main function to get version from git
get_version_from_git() {
    local name="$1"
    local is_required="${2:-}"

    echo "Getting version for project: $name" >&2
    echo "Expected tag format: ${name}_v_X.Y.Z or ${name}_v_X.Y.Z.W" >&2

    local tag
    tag=$(get_last_tag_with "$name" "$is_required")

    if [ -n "$tag" ]; then
        parse_version_from_tag "$tag" "${name}_v_" "."
    else
        return 1
    fi
}

# Usage example
if [ "$#" -eq 0 ]; then
    echo "Usage: $0 <project-name> [REQUIRED]" >&2
    exit 1
fi

get_version_from_git "$@"
