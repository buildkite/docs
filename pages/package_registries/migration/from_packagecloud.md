# Export from Packagecloud

To migrate your packages from Packagecloud to Buildkite Package Registries, you'll need to export/download packages from a Packagecloud repository before importing them to your Buildkite registry.

## Before you begin

- Create the target registries in Buildkite Package Registries, one per ecosystem you plan to migrate.
- Generate a registry write token (or use OIDC from Buildkite Pipelines) and confirm you can publish to a test registry.
- Decide whether to preserve existing coordinates exactly (name, version, distro/arch) or to rationalize them during migration.
- For distro ecosystems (deb, rpm, alpine), plan new repo signing keys and apt/yum repo entries for consumers.

## What to export from packagecloud

You’ll export the original package files and, where practical, the basic metadata (name, version, distribution/architecture). For each ecosystem below, we outline reliable ways to fetch packages.

### Common export approaches

- Web UI: Download individual files for low volume.
- API/CLI scripted download: List and download all files for a repo.
- Native manager: If you have a canonical list of versions, pull them using the native client and re-publish.

> 📘 Tip
> Keep original filenames intact during export; many ecosystems embed version and coordinates in filenames.

## Ecosystem-specific export and import

Below are proven patterns. For imports, favor Buildkite API for distro and “file” types, and native tools for language ecosystems.

### Debian/Ubuntu (deb)

Export from packagecloud

- Use packagecloud API to enumerate packages for a repo and download .deb files.
- Preserve distro codename and architecture labels for later mapping.

Import to Buildkite Package Registries.

- Create a Debian registry in Buildkite Package Registries.
- Publish using curl or Buildkite CLI:

```bash
# REST API (token auth)
curl -H "Authorization: Bearer $TOKEN" \
 -X POST "[https://api.buildkite.com/v2/packages/organizations/$ORG/registries/$REG/packages](https://api.buildkite.com/v2/packages/organizations/$ORG/registries/$REG/packages)" \
 -F "file=@./path/to/your_1.2.3_amd64.deb"
```

Nuances and differences

- any/any support: If a package is truly distribution-agnostic, you can publish it once as deb “any/any” instead of duplicating per distro.
- APT signing keys: Buildkite Package Registries will sign repository metadata with your Buildkite key, not the legacy packagecloud key. Plan a rollout for updating consumer apt sources and keys.

### Red Hat (RPM)

Export from packagecloud

- Use packagecloud API to list and download .rpm files per repo.

Import to Buildkite Package Registries

- Create an RPM registry in BK
- Publish via REST API or CLI:

```bash
curl -H "Authorization: Bearer $TOKEN" \
 -X POST "[https://api.buildkite.com/v2/packages/organizations/$ORG/registries/$REG/packages](https://api.buildkite.com/v2/packages/organizations/$ORG/registries/$REG/packages)" \
 -F "file=@./path/to/your-1.2.3-1.x86_64.rpm"
```

Nuances and differences

- any/any-like patterns: If binaries are distro-agnostic, publish a single RPM where appropriate rather than per minor distro.
- YUM/DNF metadata is signed by Buildkite; rotate/import the new key on consumers.

### Alpine (apk)

Export

- Enumerate and download .apk files from packagecloud.

Import

```bash
curl -H "Authorization: Bearer $TOKEN" \
 -X POST "[https://api.buildkite.com/v2/packages/organizations/$ORG/registries/$REG/packages](https://api.buildkite.com/v2/packages/organizations/$ORG/registries/$REG/packages)" \
 -F "file=@./path/to/pkg-1.2.3-r0.apk"
```

### Files (generic binaries)

Export

- Download original files as-is. Keep filenames stable; BK will validate and extract semver for Anyfile where applicable.

Import

```bash
curl -H "Authorization: Bearer $TOKEN" \
 -X POST "[https://api.buildkite.com/v2/packages/organizations/$ORG/registries/$REG/packages](https://api.buildkite.com/v2/packages/organizations/$ORG/registries/$REG/packages)" \
 -F "file=@./artifact-1.2.3+build.json"
```

Notes

- Buildkite Package Registries validates filenames for semver where configured; files without version may be treated as 0.0.0 by legacy tools. Consider normalizing names during migration.

### Python (PyPI)

Export

- Download sdist/wheel files (*.tar.gz,* .whl) for each release.

Import (use native tool)

```bash
# Twine to Buildkite PyPI registry
python -m twine upload \
  --repository-url [https://packages.buildkite.com/$ORG/$REG/pypi/](https://packages.buildkite.com/$ORG/$REG/pypi/) \
  -u buildkite -p $TOKEN \
  dist/*
```

### Java (Maven/Gradle)

Export

- Download all coordinates (groupId/artifactId/version) contents: .jar, pom, checksums, signatures.

Import (use native tool)

- Maven deploy or Gradle publish to BK Maven registry, preserving GAV coordinates.

```xml
<!-- settings.xml server -->
<server>
  <id>bk-maven</id>
  <username>buildkite</username>
  <password>${env.TOKEN}</password>
</server>
```

```bash
mvn deploy -DaltDeploymentRepository=bk-maven::default::[https://packages.buildkite.com/$ORG/$REG/maven/](https://packages.buildkite.com/$ORG/$REG/maven/)
```

### JavaScript (npm)

Export

- Pull tarballs for each version, or reconstruct from registry metadata.

Import (use native tool)

```bash
npm set //[packages.buildkite.com/$ORG/$REG/npm/:_authToken=$TOKEN](http://packages.buildkite.com/$ORG/$REG/npm/:_authToken=$TOKEN)
npm publish
```

### Ruby (RubyGems)

Export

- Download .gem files and associated metadata files if present.

Import (use native tool)

```bash
gem push --key buildkite --host [https://packages.buildkite.com/$ORG/$REG/gems/](https://packages.buildkite.com/$ORG/$REG/gems/) pkg-1.2.3.gem
```

### NuGet (.NET)

Export

- Download .nupkg and .nuspec where applicable.

Import (use native tool)

```bash
# dotnet nuget push
dotnet nuget push *.nupkg \
  --source [https://packages.buildkite.com/$ORG/$REG/nuget/v3/index.json](https://packages.buildkite.com/$ORG/$REG/nuget/v3/index.json) \
  --api-key $TOKEN
```

### OCI images and Helm (OCI)

Export

- Pull images/charts and retag locally.

Import (use native tool)

```bash
# Docker/OCI
docker login [packages.buildkite.com/$ORG/$REG](http://packages.buildkite.com/$ORG/$REG) -u buildkite -p $TOKEN
docker tag src:1.2.3 [packages.buildkite.com/$ORG/$REG/src:1.2.3](http://packages.buildkite.com/$ORG/$REG/src:1.2.3)
docker push [packages.buildkite.com/$ORG/$REG/src:1.2.3](http://packages.buildkite.com/$ORG/$REG/src:1.2.3)
```

## End-to-end scripted migration (pattern)

1. Enumerate all packages in a packagecloud repo via API and write a manifest (JSON) of filenames and coordinates.
1. Download files to a staging directory that mirrors ecosystem structure.
1. For each ecosystem, publish using the recommended method above.
1. Verify availability using the ecosystem’s discovery endpoints or search.
1. Switch users to Buildkite Package Registries URLs and keys.

Pseudo-shell

```bash
set -euo pipefail
SRC_MANIFEST=pc-export.json
STAGING=./export

# 1. enumerate (ecosystem-specific; produce $SRC_MANIFEST)
# 2. download
jq -r '.files[].url' "$SRC_MANIFEST" | while read -r u; do
  curl -SsL -O --output-dir "$STAGING" "$u"
done

# 3. import (example: deb)
for f in $(find "$STAGING/deb" -name '*.deb'); do
  curl -H "Authorization: Bearer $TOKEN" \
   -X POST "[https://api.buildkite.com/v2/packages/organizations/$ORG/registries/$DEB_REG/packages](https://api.buildkite.com/v2/packages/organizations/$ORG/registries/$DEB_REG/packages)" \
   -F "file=@$f"
done
```

## Known differences and caveats

- Index signing keys: APT/YUM metadata is signed by Buildkite Package Registries' keys. Plan a key rotation and update consumer repo setup accordingly.
- any/any: Buildkite Package Registries supports true “any/any” for deb and rpm. If you duplicated uploads per distro previously, you can simplify to one upload per version.
- File naming and version validation: Buildkite Package Registries may enforce clearer version parsing for generic files; normalize filenames if needed.
- Download/install counts: Historical analytics typically aren’t migrated. Preserve them offline if you need a record.

### Packagecloud vs Buildkite Package Registries: key differences (deb/rpm and files)

| Area | packagecloud | Buildkite Package Registries | Migration guidance |
| --- | --- | --- | --- |
| Deb/RPM repo signing keys | Repo metadata signed with packagecloud global key for your repo | Repo metadata signed with your BK registry key | Plan a key rotation. Distribute the Buildkite Package Registries public key and update consumer apt/yum repo definitions during cutover. |
| any/any usage (Deb/RPM) | Common to duplicate binaries per distro/version even if identical | Supports true "any/any" publication when binaries are distro-agnostic | Publish once per version using any/any to reduce duplication. Keep per-distro builds only when binaries or deps differ. |
| File validation and naming (generic files) | Heuristic filename handling. Missing versions may be treated as 0.0.0 | Stricter filename parsing and semver validation for generic files (where enabled) | Normalize filenames to include clear name and version before import. Adjust scripts if any uploads fail validation. |

## Validation checklist

- Packages appear in Buildkite Package Registries with correct names and versions.
- Search/metadata endpoints respond correctly for language registries.
- apt/yum update succeeds and installs fetch the expected versions.
- Docker/OCI pulls succeed for expected tags.
- Consumers have rotated to Buildkite Package Registries repo URLs and keys.

## Appendix: Minimal curl patterns for Buildkite Package Registries

```bash
# Generic distro/file upload pattern
curl -H "Authorization: Bearer $TOKEN" \
 -X POST "[https://api.buildkite.com/v2/packages/organizations/$ORG/registries/$REG/packages](https://api.buildkite.com/v2/packages/organizations/$ORG/registries/$REG/packages)" \
 -F "file=@/path/to/file"
```

```bash
# OIDC in a Buildkite step to get a short-lived token
buildkite_api_token=$(buildkite-agent oidc request-token --audience "[https://packages.buildkite.com](https://packages.buildkite.com)" --lifetime 300)
BUILDKITE_API_TOKEN=$buildkite_api_token \
  curl -H "Authorization: Bearer $buildkite_api_token" \
   -X POST "[https://api.buildkite.com/v2/packages/organizations/$ORG/registries/$REG/packages](https://api.buildkite.com/v2/packages/organizations/$ORG/registries/$REG/packages)" \
   -F "file=@/path/to/file"
```

Outcome: a clean export of original artifacts, simplified any/any usage for distro packages, and reproducible imports using native tooling where it matters, or Buildkite Package Registries’s unified API where it shines.

## Next step

Once you have downloaded your packages from your Packagecloud repositories, learn how to [import them into your Buildkite registry](/docs/package-registries/migration/import-to-package-registries).
