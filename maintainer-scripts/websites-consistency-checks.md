# website-consistency-checks.md

Various commands to check the consistency of the +20 websites.

## package.json

for f in /Users/ilg/MyProjects/xpack-dev-tools.github/xPacks/*/build-assets/package.json; do echo; echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'; echo $f; liquidjs --context @$f --template '{{ xpack.properties.customFields | json }}' | json_pp; echo; done

## getting-started

for f in /Users/ilg/MyProjects/xpack-dev-tools.github/xPacks/*/website/docs/getting-started/_overview.mdx; do echo $f; cat $f; echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'; done

for f in /Users/ilg/MyProjects/xpack-dev-tools.github/xPacks/*/website/docs/getting-started/_compatibility.mdx; do echo $f; cat $f; echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'; done

for f in /Users/ilg/MyProjects/xpack-dev-tools.github/xPacks/*/website/docs/getting-started/_documentation.mdx; do echo $f; cat $f; echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'; done

for f in /Users/ilg/MyProjects/xpack-dev-tools.github/xPacks/*/website/docs/getting-started/_release-schedule.mdx; do echo $f; cat $f; echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'; done

for f in /Users/ilg/MyProjects/xpack-dev-tools.github/xPacks/*/website/docs/getting-started/_upgrade-notice.mdx; do echo $f; cat $f; echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'; done

## install

for f in /Users/ilg/MyProjects/xpack-dev-tools.github/xPacks/*/website/docs/install/_folder-hierarchies.mdx; do echo $f; cat $f; echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'; done

for f in /Users/ilg/MyProjects/xpack-dev-tools.github/xPacks/*/website/docs/install/_miscellaneous.mdx; do echo $f; cat $f; echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'; done

for f in /Users/ilg/MyProjects/xpack-dev-tools.github/xPacks/*/website/docs/install/_testing.mdx; do echo $f; cat $f; echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'; done

## user

for f in /Users/ilg/MyProjects/xpack-dev-tools.github/xPacks/*/website/docs/user/_more.mdx; do echo $f; cat $f; echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'; done

for f in /Users/ilg/MyProjects/xpack-dev-tools.github/xPacks/*/website/docs/user/_use-in-testing.mdx; do echo $f; cat $f; echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'; done

for f in /Users/ilg/MyProjects/xpack-dev-tools.github/xPacks/*/website/docs/user/_versioning.mdx; do echo $f; cat $f; echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'; done

## developer

for f in /Users/ilg/MyProjects/xpack-dev-tools.github/xPacks/*/website/docs/developer/_more.mdx; do echo $f; cat $f; echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'; done

for f in /Users/ilg/MyProjects/xpack-dev-tools.github/xPacks/*/website/docs/developer/_other-repositories.mdx; do echo $f; cat $f; echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'; done

## maintainer

for f in /Users/ilg/MyProjects/xpack-dev-tools.github/xPacks/*/website/docs/maintainer/_check-upstream-release.mdx; do echo $f; cat $f; echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'; done

for f in /Users/ilg/MyProjects/xpack-dev-tools.github/xPacks/*/website/docs/maintainer/_first-development-run.mdx; do echo $f; cat $f; echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'; done

for f in /Users/ilg/MyProjects/xpack-dev-tools.github/xPacks/*/website/docs/maintainer/_first-production-run.mdx; do echo $f; cat $f; echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'; done

for f in /Users/ilg/MyProjects/xpack-dev-tools.github/xPacks/*/website/docs/maintainer/_more-repos.mdx; do echo $f; cat $f; echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'; done

for f in /Users/ilg/MyProjects/xpack-dev-tools.github/xPacks/*/website/docs/maintainer/_more-tests.mdx; do echo $f; cat $f; echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'; done

for f in /Users/ilg/MyProjects/xpack-dev-tools.github/xPacks/*/website/docs/maintainer/_patches.mdx; do echo $f; cat $f; echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'; done

for f in /Users/ilg/MyProjects/xpack-dev-tools.github/xPacks/*/website/docs/maintainer/_share-custom.mdx; do echo $f; cat $f; echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'; done

for f in /Users/ilg/MyProjects/xpack-dev-tools.github/xPacks/*/website/docs/maintainer/_update-version-specific.mdx; do echo $f; cat $f; echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'; done

---
