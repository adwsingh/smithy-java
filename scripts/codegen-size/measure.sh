#!/usr/bin/env bash
#
# Measures the size of the code generated for a model by the codegen of a given checkout.
#
#   scripts/codegen-size/measure.sh <checkout> <model.jar|model.json> <out.json> [report options...]
#
# Builds the codegen plugin in <checkout>, then runs CodegenSize.java from this directory (not
# from <checkout>) against it, so any two commits can be compared with the same tool. Extra
# arguments go to the "report" command, for example "--baseline base.json --markdown report.md".
# JVM options default to -Xmx6g and can be overridden with CODEGEN_SIZE_JAVA_OPTS.
set -euo pipefail

if [ "$#" -lt 3 ]; then
    echo "usage: $0 <checkout> <model.jar|model.json> <out.json> [report options...]" >&2
    exit 2
fi

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
checkout=$1
model=$2
out=$3
shift 3

absolute() {
    case "$1" in
        /*) printf '%s\n' "$1" ;;
        *) printf '%s/%s\n' "$PWD" "$1" ;;
    esac
}
model=$(absolute "$model")
out=$(absolute "$out")

classpath_file=$(mktemp "${TMPDIR:-/tmp}/codegen-size-classpath.XXXXXX")
trap 'rm -f "$classpath_file"' EXIT

echo "Building the codegen plugin in $checkout" >&2
(cd "$checkout" && ./gradlew -q -I "$here/codegen-size.init.gradle" \
    :codegen:codegen-plugin:codegenSizeClasspath "-PcodegenSizeClasspathFile=$classpath_file")

# shellcheck disable=SC2086  # CODEGEN_SIZE_JAVA_OPTS intentionally holds several options
java ${CODEGEN_SIZE_JAVA_OPTS:--Xmx6g} -cp "$(cat "$classpath_file")" "$here/CodegenSize.java" \
    report --model "$model" --out "$out" "$@"
