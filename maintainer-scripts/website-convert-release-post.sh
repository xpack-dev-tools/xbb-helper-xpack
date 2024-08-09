#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Safety settings (see https://gist.github.com/ilg-ul/383869cbb01f61a51c4d).

if [[ ! -z ${DEBUG} ]]
then
  set ${DEBUG} # Activate the expand mode if DEBUG is anything but empty.
else
  DEBUG=""
fi

set -o errexit # Exit if command failed.
set -o pipefail # Exit if pipe failed.
set -o nounset # Exit if variable not set.

# Remove the initial space and instead use '\n'.
IFS=$'\n\t'

# -----------------------------------------------------------------------------
# Identify the script location, to reach, for example, the helper scripts.

script_path="$0"
if [[ "${script_path}" != /* ]]
then
  # Make relative path absolute.
  script_path="$(pwd)/$0"
fi

script_name="$(basename "${script_path}")"

script_folder_path="$(dirname "${script_path}")"
script_folder_name="$(basename "${script_folder_path}")"

# =============================================================================

# Explicit display of failures.
# Return 255, required by `xargs` to stop when invoked via `find`.
function trap_handler()
{
  local from_file="$1"
  shift
  local line_number="$1"
  shift
  local exit_code="$1"
  shift

  echo "FAIL ${from_file} line: ${line_number} exit: ${exit_code}"
  return 255
}

# -----------------------------------------------------------------------------

# echo $@

# The source file name.
from=$(echo "$1" | sed -e 's|^\.\/||')

# The destination file name. Change `.md` to `.mdx`.
to=$(echo "$from" | sed -e 's|-liquid||')x
# echo $from

# Used to enforce an exit code of 255, required by xargs.
trap 'trap_handler ${from} $LINENO $?; return 255' ERR

if [ -f "$2/$to" ] && [ "${doForce}" == "n" ]
then
  echo "$2/$to already present"
  exit 0
fi

mkdir -p "$(dirname $2/$to)"

# Copy from Jekyll to local web.
cp -v "$from" "$2/$to"

# Get the value of `date:` to generate it in a higher position.
date="$(grep -e '^date: ' "$2/$to" | sed -e 's|^date:[[:space:]]*||')"

# Get the value of `summary` to generate the first short paragraph.
summary="$(grep -e '^summary: ' "$2/$to" | sed -e 's|^summary:[[:space:]]*||' || true)"
if [ ! -z "${summary}" ] && [ "${summary:0:1}" == "\"" ]
then
  summary="$(echo ${summary} | sed -e 's|^"||' -e 's|"$||')"
fi

# Remove `date:`, will be generated right after the title.
sed -i.bak -e '/^date:/d' "$2/$to"

# Remove `summary:`, will be added as first short paragraph.
sed -i.bak -e '/^summary:/d' "$2/$to"

# Remove `sidebar:`.
sed -i.bak -e '/^sidebar:/d' "$2/$to"

# Add mandatory front matter properties (authors, tags, date) after title.
s="/^title:/ { print; print \"\"; print \"date: ${date}\"; print \"\"; print \"authors: ilg-ul\"; print \"\"; print \"# To be listed in the Releases page.\"; print \"tags:\"; print \"  - releases\"; print \"\"; print \"# ----- Custom properties -----------------------------------------------------\";next }1"
awk "$s" "$2/$to" >"$2/$to.new" && mv -f "$2/$to.new" "$2/$to"

# Fix the badge to releases.
s="  - this release <a href={ \`https://github.com/xpack-dev-tools/${appLcName}-xpack/releases/v\$\{ frontMatter.version }/\` } ><Image img={ \`https://img.shields.io/github/downloads/xpack-dev-tools/${appLcName}-xpack/v\$\{ frontMatter.version }/total.svg\` } alt='Github Release' /></a>"
sed -i.bak -e "s|  - this release ...Github All Releases.*|$s|" "$2/$to"

# Add the yaml end tag after download_url and a custom tag for the delete.
if grep '<Image ' "$2/$to" >/dev/null
then
  s="/download_url:/ { print; print \"\"; print \"---\"; print \"\"; print \"import Image from '@theme/IdealImage';\"; print \"--e-n-d-\"; next }1"
else
  s="/download_url:/ { print; print \"\"; print \"---\"; print \"--e-n-d-\"; next }1"
fi
awk "$s" "$2/$to" >"$2/$to.new" && mv -f "$2/$to.new" "$2/$to"

# Remove extra frontmatter properties.
sed -i.bak -e '/^--e-n-d-$/,/^---$/d' "$2/$to"

# Add summary to post body.
if [ ! -z "${summary}" ]
then
  s="BEGIN {count=0;} /^---$/ { count+=1; print; if (count == 2) { print \"\"; print \"${summary}\"; print \"\"; print \"<!-- truncate -->\";} next }1"
  awk "$s" "$2/$to" >"$2/$to.new" && mv -f "$2/$to.new" "$2/$to"
fi

# Convert admonition.
awk '/{% include note.html content="The main targets for the GNU.Linux Arm/ { print ":::note Raspberry Pi"; print ""; print "The main targets for the GNU/Linux Arm"; next }1' "$2/$to" >"$2/$to.new" && mv -f "$2/$to.new" "$2/$to"
awk '/armv6 is not supported)." %}/ { print "armv6 is not supported)."; print ""; print ":::";next }1' "$2/$to" >"$2/$to.new" && mv -f "$2/$to.new" "$2/$to"

# Convert admonition.
awk '/{% include important.html content="It is mandatory for the applications to/ { print ":::caution"; print ""; print "It is mandatory for the applications to"; next }1' "$2/$to" >"$2/$to.new" && mv -f "$2/$to.new" "$2/$to"
awk '/`-mcmodel=medany`, otherwise the link might fail." %}/ { print "`-mcmodel=medany`, otherwise the link might fail."; print ""; print ":::"; next }1' "$2/$to" >"$2/$to.new" && mv -f "$2/$to.new" "$2/$to"

# Convert admonition.
awk '/{% include note.html content="Starting with 2022 \(GCC 11.3\), the/ { print ":::note"; print ""; print "Starting with 2022 (GCC 11.3), the"; next }1' "$2/$to" >"$2/$to.new" && mv -f "$2/$to.new" "$2/$to"
awk '/to `riscv-none-elf-gcc`." %}/ { print "to `riscv-none-elf-gcc`."; print ""; print ":::"; next }1' "$2/$to" >"$2/$to.new" && mv -f "$2/$to.new" "$2/$to"

# Convert admonition.
awk '/{% include warning.html content="In certain cases, on 32-bit platforms, this/ { print ":::caution"; print ""; print "n certain cases, on 32-bit platforms, this"; next }1' "$2/$to" >"$2/$to.new" && mv -f "$2/$to.new" "$2/$to"
awk '/command might fail with _RangeError: Array buffer allocation failed_." %}/ { print "command might fail with _RangeError: Array buffer allocation failed_."; print ""; print ":::"; next }1' "$2/$to" >"$2/$to.new" && mv -f "$2/$to.new" "$2/$to"

# Convert admonition.
awk '/{% include note.html content="TUI is not available on Windows." %}/ { print ":::note"; print ""; print "TUI is not available on Windows";print ""; print ":::"; next }1' "$2/$to" >"$2/$to.new" && mv -f "$2/$to.new" "$2/$to"

# Convert admonition.
awk '/{% include note.html content="Due to memory limitations during the build, there is no Arm 32-bit image." %}/ { print ":::note"; print ""; print "Due to memory limitations during the build, there is no Arm 32-bit image."; print ""; print ":::"; next }1' "$2/$to" >"$2/$to.new" && mv -f "$2/$to.new" "$2/$to"

# Convert ninja-build admonition.
awk '/{% include note.html content="For consistency with the Node.js naming/ { print ":::note"; print ""; print "For consistency with the Node.js naming conventions, the names of the Intel 32-bit images are now suffixed with `-ia32`."; print ""; print ":::"; next }1' "$2/$to" >"$2/$to.new" && mv -f "$2/$to.new" "$2/$to"

# convert arm-none-eabi-gcc admonition.
awk '/{% include note.html content="Compared to the Arm distribution/ { print ":::note"; print ""; print "Compared to the Arm distribution, the Aarch64 binaries are not yet available."; print ""; print ":::"; next }1' "$2/$to" >"$2/$to.new" && mv -f "$2/$to.new" "$2/$to"

# convert arm-none-eabi-gcc admonition.
awk '/{% include note.html content="Release 10.3.1-1.1, corresponding to Arm release/ { print ":::note"; print ""; print "Release 10.3.1-1.1, corresponding to Arm release 10.3-2021.07, was skipped."; print ""; print ":::"; next }1' "$2/$to" >"$2/$to.new" && mv -f "$2/$to.new" "$2/$to"

# convert qemu-arm admonition.
awk '/% include note.html content="The method to select the path/ { print ":::note"; print ""; print "The method to select the path based on the xPack version was already added to the Eclipse plug-in, but for now is only available in the version published on the test site (https://gnu-mcu-eclipse.netlify.com/v4-neon-updates-test/)."; print ""; print ":::"; next }1' "$2/$to" >"$2/$to.new" && mv -f "$2/$to.new" "$2/$to"

# convert qemu-arm admonition.
awk '/{% include warning.html content="In this old release/ { print ":::caution"; print ""; print "In this old release, support for hardware floating point on Cortex-M4 devices is not available."; print ""; print ":::"; next }1' "$2/$to" >"$2/$to.new" && mv -f "$2/$to.new" "$2/$to"

# convert windows-build-tools admonition.
awk '/{% include note.html content="In preparation for the xPack distribution,/ { print ":::note"; print ""; print "In preparation for the xPack distribution, only portable archives are provided; Windows setups are no longer supported."; print ""; print ":::"; next }1' "$2/$to" >"$2/$to.new" && mv -f "$2/$to.new" "$2/$to"

# convert windows-build-tools admonition.
awk '/{% include note.html content="By design, installing the xPack binaries/ { print ":::note"; print ""; print "By design, installing the xPack binaries does not require administrative rights, thus only portable archives are provided; Windows setups are no longer supported."; print ""; print ":::"; next }1' "$2/$to" >"$2/$to.new" && mv -f "$2/$to.new" "$2/$to"

# convert windows-build-tools admonition.
awk '/{% include warning.html content="This version is affected by the Windows UCRT bug/ { print ":::caution"; print ""; print "This version is affected by the Windows UCRT bug, `make` throws _Error -1073741819_; please use v4.3.x or later. Thank you for your understanding."; print ""; print ":::"; next }1' "$2/$to" >"$2/$to.new" && mv -f "$2/$to.new" "$2/$to"

# Remove from Easy install to Compliance.
if grep '### Easy install' "$2/$to" >/dev/null && grep '## Compliance' "$2/$to" >/dev/null
then
  awk '/## Compliance/ {print "--e-n-d-"; print; next }1' "$2/$to" >"$2/$to.new" && mv -f "$2/$to.new" "$2/$to"

  sed -i.bak -e '/^### Easy install$/,/^--e-n-d-$/d' "$2/$to"
fi

# Remove from ## Shared libraries to ## Documentation.
if grep '## Shared libraries' "$2/$to" >/dev/null && grep '## Documentation' "$2/$to" >/dev/null
then
  awk '/## Documentation/ { print "--e-n-d-"; print; next }1' "$2/$to" >"$2/$to.new" && mv -f "$2/$to.new" "$2/$to"

  sed -i.bak -e '/^## Shared libraries$/,/^--e-n-d-$/d' "$2/$to"
fi

# Change link to GitHub Releases to html to allow variables.
sed -i.bak -e 's|\[GitHub Releases\]... page.download_url ...|<a href={ frontMatter.download_url }>GitHub Releases</a>|' "$2/$to"

# Change link to binary files to html to allow variables.
if grep -e 'Binary files .* page.download_url' "$2/$to" >/dev/null
then
  awk '/Binary files .* page.download_url/ { print "<!-- truncate -->"; print ""; print; next }1' "$2/$to" >"$2/$to.new" && mv -f "$2/$to.new" "$2/$to"

  sed -i.bak -e 's|^.Binary files ..... page.download_url ...|<p><a href={ frontMatter.download_url }>Binary files »</a></p>|' "$2/$to"
fi

# Fix RISC-V references to Install.
sed -i.bak -e 's|the separate \[How to install the RISC-V toolchain\?\].{{ site.baseurl }}/riscv-none-embed-gcc/install/. page.|the project [README](https://github.com/xpack-dev-tools/riscv-none-embed-gcc-xpack).|' "$2/$to"

sed -i.bak -e 's|separate .Install.... site.baseurl ../riscv-none-embed-gcc/install/. page.|project [README](https://github.com/xpack-dev-tools/riscv-none-embed-gcc-xpack).|' "$2/$to"

sed -i.bak -e 's|separate .Install.... site.baseurl ../dev-tools/riscv-none-elf-gcc/install/. page.|[Install Guide](/docs/install/).|' "$2/$to"

# Fix other references to Install.
sed -i.bak -e 's|separate \[.*\]... site.baseurl ../dev-tools/.*/install/) page|[Install Guide](/docs/install/)|' "$2/$to"
sed -i.bak -e 's|\[.*\]... site.baseurl ../dev-tools/.*/install/)|[Install Guide](/docs/install/)|' "$2/$to"

# Fix references to README-BUILD.md.
s="[Maintainer Info](/docs/maintainer/)"
sed -i.bak -e "s|.How to build..https://github.com/xpack-dev-tools/.*-xpack/blob/xpack/README-BUILD.md.|$s|" "$2/$to"

# Convert parametrised link to html.
sed -i.bak -e "s|.{{ page.upstream_commit }}..https://github.com/openocd-org/[a-z-]*/commit/{{ page.upstream_commit }}/)|<a href={ \`https://github.com/openocd-org/${appLcName}/commit/\$\{ frontMatter.upstream_commit }/\` }>{ frontMatter.upstream_commit }</a>|" "$2/$to"

# Fix openocd documentation autolink.
sed -i.bak -e "s|- <https://openocd.org/doc/pdf/openocd.pdf>|- https://openocd.org/doc/pdf/openocd.pdf|" "$2/$to"

# Fix openocd code blocks.
s='/```sh/{N;N;s|```sh\n~/Library/xPacks/@xpack-dev-tools/openocd/{{ page.version }}.{{ page.npm_subversion }}/.content/bin/openocd -f board/stm32f4discovery.cfg\n```|<CodeBlock language="sh"> {\n`~/Library/xPacks/@xpack-dev-tools/openocd/${ frontMatter.version }.${ frontMatter.npm_subversion }/.content/bin/openocd -f board/stm32f4discovery.cfg`\n} </CodeBlock>|;}'
sed -i.bak -e "$s" "$2/$to"

s='/```sh/{N;s|```sh\n~/Library/xPacks/@xpack-dev-tools/openocd/{{ page.version }}.{{ page.npm_subversion }}/.content/bin/openocd -f board/stm32f4discovery.cfg|<CodeBlock language="console"> {\n`% ~/Library/xPacks/@xpack-dev-tools/openocd/${ frontMatter.version }.${ frontMatter.npm_subversion }/.content/bin/openocd -f board/stm32f4discovery.cfg|;}'
sed -i.bak -e "$s" "$2/$to"

# Add 'import CodeBlock ...'.
if grep '<CodeBlock' "$2/$to" >/dev/null
then
  s="/import Image from / { print; print \"import CodeBlock from '@theme/CodeBlock';\"; next }1"
  awk "$s" "$2/$to" >"$2/$to.new" && mv -f "$2/$to.new" "$2/$to"
fi

s='/\^Cshutdown command invoked/{N;s|\^Cshutdown command invoked\n```|^Cshutdown command invoked`\n} </CodeBlock>|;}'
sed -i.bak -e "$s" "$2/$to"

# Preserve Eclipse variable syntax.
sed -i.bak -e 's|update the \`${openocd_path}\` variable|update the `$\\{openocd_path\\}` variable|' "$2/$to"

# Fix links to tests.
sed -i.bak -e "s|/dev-tools/${appLcName}/tests/|/docs/tests/|" "$2/$to"

# Fix project web path
sed -i.bak -e 's|https://xpack.github.io/dev-tools/\([a-z-]*\)/|https://xpack-dev-tools.github.io/\1-xpack|' "$2/$to"

# Replace `page.` with `frontMatter.` when using variables.
sed -i.bak -e 's|{{ page[.]\([a-z0-9_]*\) }}|{ frontMatter.\1 }|g' "$2/$to"

# Fix local images url.
sed -i.bak -e 's|{{ site.baseurl }}/assets/images|/img|g' "$2/$to"

# Fix link to tests results.
sed -i.bak -e 's|/dev-tools/gcc/|/docs/|g' "$2/$to"

# Remove the `site.baseurl` from links.
sed -i.bak -e 's|{{ site.baseurl }}||g' "$2/$to"

# Squeeze multiple adjacent empty lines.
cat -s "$2/$to" >"$2/$to.new" && rm -f "$2/$to" && mv -f "$2/$to.new" "$2/$to"

rm -f "$2/$to.bak"

# -----------------------------------------------------------------------------
