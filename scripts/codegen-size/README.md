# Codegen size

Tools that measure how much Java code the codegen plugin generates for an AWS model, and how a
change affects it. The `Codegen Size` GitHub workflow runs them on every pull request that touches
`codegen/` and posts a comparison against the base commit as a comment (see
`.github/workflows/codegen-size.yml` and `codegen-size-comment.yml`).

* `CodegenSize.java` runs the plugin in memory for one service, compiles the output with the
  running JDK (`--release 21 -g`), packs it into an in-memory jar and writes a JSON report with
  totals, a per-category breakdown (structure, operation, enum, union, error, schemas, serde,
  client, resources) and per-class sizes. With `--baseline` it also writes a markdown comparison.
* `codegen-size.init.gradle` adds two tasks to `:codegen:codegen-plugin` without touching the
  build: `codegenSizeClasspath` writes the classpath needed to run the plugin and compile its
  output, `codegenSizeModel` copies an AWS model jar at the version pinned by the `aws-api-models`
  BOM.
* `measure.sh` ties the two together for one checkout.

Everything is kept out of the Gradle build on purpose. The base commit of a pull request may not
contain these files, so the tool from the pull request is run against the classpath of both
checkouts.

## Running locally

```sh
# Resolve the EC2 model once.
./gradlew -I scripts/codegen-size/codegen-size.init.gradle :codegen:codegen-plugin:codegenSizeModel \
    -PcodegenSizeModelFile=build/codegen-size/ec2.jar

# Measure a baseline checkout (for example a worktree of main) and then this one.
git worktree add /tmp/smithy-java-base main
scripts/codegen-size/measure.sh /tmp/smithy-java-base build/codegen-size/ec2.jar build/codegen-size/base.json
scripts/codegen-size/measure.sh . build/codegen-size/ec2.jar build/codegen-size/pr.json \
    --baseline build/codegen-size/base.json --markdown build/codegen-size/report.md
```

Useful `report` options: `--modes client,server` (default `client`), `--service <shape id>` for
models with several services, `--dump <dir>` to write the generated sources, classes and jar for
inspection. `CodegenSize.java compare base.json pr.json` re-renders the markdown from two reports
and only needs `smithy-model` on the classpath.
