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
# Inits and validations.

# echo $@

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

# The source file name.
from_path=$(echo "$1" | sed -e 's|^\.\/||')

# The destination file name. Change `.md` to `.mdx`.
to_path="${2}/$(basename "${from_path}" | sed -e 's|-liquid||')x"
# echo ${from_path}

# Used to enforce an exit code of 255, required by xargs.
trap 'trap_handler ${from_path} $LINENO $?; return 255' ERR

if [ -f "${to_path}" ] && [ "${doForce}" == "n" ]
then
  echo "${to_path} already present"
  exit 0
fi

tmp_awk_file="$(mktemp) -t awk"

mkdir -p "$(dirname ${to_path})"

# Copy from Jekyll to local web.
cp -v "${from_path}" "${to_path}"

# -----------------------------------------------------------------------------
# Get variables from frontmatter.

# Get the value of `date:` to generate it in a higher position.
date="$(grep -e '^date: ' "${to_path}" | sed -e 's|^date:[[:space:]]*||')"

# Get the value of `summary` to generate the first short paragraph.
summary="$(grep -e '^summary: ' "${to_path}" | sed -e 's|^summary:[[:space:]]*||' || true)"
if [ ! -z "${summary}" ] && [ "${summary:0:1}" == "\"" ]
then
  summary="$(echo ${summary} | sed -e 's|^"||' -e 's|"$||')"
fi

# Get the value of `app_name` to generate the first short paragraph.
post_app_name="$(grep -e '^app_name: ' "${to_path}" | sed -e 's|^app_name:[[:space:]]*||' -e 's|["]||g' || true)"
# echo "<<a< $post_app_name >>>"

description="$(echo ${summary} | sed -e 's| of .*|.|')"
description="$(echo ${description} | sed -e 's|;.*|.|')"
description="$(echo ${description} | sed -e 's|,.*|.|')"

description="$(echo ${description} | sed -e 's|\*\*||g' -e 's|DO NOT USE! ||' -e 's|DEPRECATED: ||' -e 's|  | |g')"
if [ ! -z "${post_app_name}" ]
then
  s="s|[.]$| of ${post_app_name}.|"
  description="$(echo ${description} | sed -e "${s}")"
  # s="s|[.]$| of **${post_app_name}**.|"
  # summary="$(echo ${summary} | sed -e "${s}")"
else
  s="s|[.]$| of xPack ${app_name}.|"
  description="$(echo ${description} | sed -e "${s}")"
fi

# Get the value of the title to generate seo_title
title=$(grep 'title: ' "${to_path}" | sed -e 's|^title:[ ]*||')

seo_title="${title}"
seo_title="$(echo "${seo_title}" | sed -e 's|The project has a new web site|New web site|')"
seo_title="$(echo "${seo_title}" | sed -e 's|xPack .* v|Version |')"
seo_title="$(echo "${seo_title}" | sed -e 's|GNU .* v|Version |')"

if false
then
  echo "<<s< $summary >>>"
  echo "<<d< $description >>>"
  echo "<<t< $title >>>"
  echo "<<o< $seo_title >>>"
fi

# -----------------------------------------------------------------------------
# Process the frontmatter.

# Remove `date:`, will be generated right after the title.
sed -i.bak -e '/^date:/d' "${to_path}"

# Remove `summary:`, will be added as first short paragraph.
sed -i.bak -e '/^summary:/d' "${to_path}"

# Remove `sidebar:`.
sed -i.bak -e '/^sidebar:/d' "${to_path}"

# Remove `app_name:`.
sed -i.bak -e '/^app_name:/d' "${to_path}"

# fix title: spaces
sed -i.bak -e 's|title:[ ][ ]*|title: |' "${to_path}"


# Add mandatory front matter properties (authors, tags, date) after title.

# Note: __EOF__ is not quoted to allow substitutions here.
cat <<__EOF__ > "${tmp_awk_file}"

/^title:/ {
  print

  print "seo_title: ${seo_title}"
  print "description: ${description}"
  print "keywords:"
  print "  - xpack"
  print "  - ${app_lc_name}"
  print "  - release"
  print ""
  print "date: ${date}"
  print ""
  print "authors: ilg-ul"
  print ""
  print "# To be listed in the Releases page."
  print "tags:";
  print "  - releases"
  print ""
  print "# ----- Custom properties -----------------------------------------------------"

  next
}

1

__EOF__

awk -f "${tmp_awk_file}" "${to_path}" >"${to_path}.new" && mv -f "${to_path}.new" "${to_path}"


# Add the yaml end tag after download_url and a custom tag for the delete.
# if grep '<Image ' "${to_path}" >/dev/null
# then
  s="/download_url:/ { print; print \"\"; print \"---\"; print \"\"; print \"--e-n-d-f-\"; next }1"
# else
#   s="/download_url:/ { print; print \"\"; print \"---\"; print \"--e-n-d-f-\"; next }1"
# fi
awk "$s" "${to_path}" >"${to_path}.new" && mv -f "${to_path}.new" "${to_path}"

# Add imports, summary paragraph, truncate and page title
# Note: __EOF__ is quoted to prevent substitutions here.
cat <<'__EOF__' > "${tmp_awk_file}"

BEGIN {
  count = 0
}

/^---$/ {
  count += 1

  print
  if (count == 2) {
    print ""
    print "import {PageMetadata} from '@docusaurus/theme-common';"
    print "import Image from '@theme/IdealImage';";
    print "import CodeBlock from '@theme/CodeBlock';"
__EOF__

if [ ! -z "${summary}" ]
then
# Add summary to post body.

# Note: __EOF__ is not quoted to allow substitutions here.
cat <<__EOF__ >> "${tmp_awk_file}"
    print ""
    print "${summary}"
__EOF__
fi

cat <<'__EOF__' >> "${tmp_awk_file}"
    print ""
    print "<!-- truncate -->"
    print ""
    print "<PageMetadata title={frontMatter.seo_title} />"
  }
  next
}

1

__EOF__

awk -f "${tmp_awk_file}" "${to_path}" >"${to_path}.new" && mv -f "${to_path}.new" "${to_path}"

# Remove extra frontmatter properties.
sed -i.bak -e '/^--e-n-d-f-$/,/^---$/d' "${to_path}"

# -----------------------------------------------------------------------------
# Process the post body.

# Fix the badge to releases.
s="  - this release <a href={\`https://github.com/xpack-dev-tools/${app_lc_name}-xpack/releases/v\$\{frontMatter.version}/\`} ><Image img={\`https://img.shields.io/github/downloads/xpack-dev-tools/${app_lc_name}-xpack/v\$\{frontMatter.version}/total.svg\`} alt='Github Release' /></a>"
sed -i.bak -e "s|  - this release ...Github All Releases.*|$s|" "${to_path}"


# Insert xpm install version
s="/^## Install$/ { print; print \"\"; print \"The easiest way to install this specific version, is by using **xpm**:\"; print \"\"; print \"<CodeBlock language=console> \{\"; print \"\`xpm install @xpack-dev-tools/${app_lc_name}@\${frontMatter.version}.\${frontMatter.npm_subversion} -verbose\"; print \"\`\} </CodeBlock>\"; next }1"
awk "$s" "${to_path}" >"${to_path}.new" && mv -f "${to_path}.new" "${to_path}"
sed -i.bak -e 's|CodeBlock language=console|CodeBlock language="console"|' "${to_path}"

# s="/^The full details of installing the **xPack/ { print \"Comprehensive instructions for installing **xPack ${app_name}**\"; print \"on different platforms can be found in the\"; next }1"
# awk "$s" "${to_path}" >"${to_path}.new" && mv -f "${to_path}.new" "${to_path}"

s="s|The full details of installing the ..xPack .*.. on various platforms|Comprehensive instructions for installing **xPack ${app_name}** on different platforms|"
sed -i.bak -e "${s}" "${to_path}"
s="s|are presented in the separate .Install.* page|can be found in the [Install Guide](/docs/install/)|"
sed -i.bak -e "${s}" "${to_path}"

# Convert admonition.
awk '/{% include note.html content="The main targets for the GNU.Linux Arm/ { print ":::note Raspberry Pi"; print ""; print "The main targets for the GNU/Linux Arm"; next }1' "${to_path}" >"${to_path}.new" && mv -f "${to_path}.new" "${to_path}"
awk '/armv6 is not supported)." %}/ { print "armv6 is not supported)."; print ""; print ":::";next }1' "${to_path}" >"${to_path}.new" && mv -f "${to_path}.new" "${to_path}"

# Convert admonition.
awk '/{% include important.html content="It is mandatory for the applications to/ { print ":::caution"; print ""; print "It is mandatory for the applications to"; next }1' "${to_path}" >"${to_path}.new" && mv -f "${to_path}.new" "${to_path}"
awk '/`-mcmodel=medany`, otherwise the link .* fail." %}/ { print "`-mcmodel=medany`, otherwise the link will fail."; print ""; print ":::"; next }1' "${to_path}" >"${to_path}.new" && mv -f "${to_path}.new" "${to_path}"

# Convert admonition.
awk '/{% include note.html content="Starting with 2022 \(GCC 11.3\), the/ { print ":::note"; print ""; print "Starting with 2022 (GCC 11.3), the"; next }1' "${to_path}" >"${to_path}.new" && mv -f "${to_path}.new" "${to_path}"
awk '/to `riscv-none-elf-gcc`." %}/ { print "to `riscv-none-elf-gcc`."; print ""; print ":::"; next }1' "${to_path}" >"${to_path}.new" && mv -f "${to_path}.new" "${to_path}"

# Convert admonition.
awk '/{% include warning.html content="In certain cases, on 32-bit platforms, this/ { print ":::caution"; print ""; print "n certain cases, on 32-bit platforms, this"; next }1' "${to_path}" >"${to_path}.new" && mv -f "${to_path}.new" "${to_path}"
awk '/command might fail with _RangeError: Array buffer allocation failed_." %}/ { print "command might fail with _RangeError: Array buffer allocation failed_."; print ""; print ":::"; next }1' "${to_path}" >"${to_path}.new" && mv -f "${to_path}.new" "${to_path}"

# Convert admonition.
awk '/{% include note.html content="TUI is not available on Windows." %}/ { print ":::note"; print ""; print "TUI is not available on Windows";print ""; print ":::"; next }1' "${to_path}" >"${to_path}.new" && mv -f "${to_path}.new" "${to_path}"

# Convert admonition.
awk '/{% include note.html content="Due to memory limitations during the build, there is no Arm 32-bit image." %}/ { print ":::note"; print ""; print "Due to memory limitations during the build, there is no Arm 32-bit image."; print ""; print ":::"; next }1' "${to_path}" >"${to_path}.new" && mv -f "${to_path}.new" "${to_path}"

# Convert ninja-build admonition.
awk '/{% include note.html content="For consistency with the Node.js naming/ { print ":::note"; print ""; print "For consistency with the Node.js naming conventions, the names of the Intel 32-bit images are now suffixed with `-ia32`."; print ""; print ":::"; next }1' "${to_path}" >"${to_path}.new" && mv -f "${to_path}.new" "${to_path}"

# convert arm-none-eabi-gcc admonition.
awk '/{% include note.html content="Compared to the Arm distribution/ { print ":::note"; print ""; print "Compared to the Arm distribution, the Aarch64 binaries are not yet available."; print ""; print ":::"; next }1' "${to_path}" >"${to_path}.new" && mv -f "${to_path}.new" "${to_path}"

# convert arm-none-eabi-gcc admonition.
awk '/{% include note.html content="Release 10.3.1-1.1, corresponding to Arm release/ { print ":::note"; print ""; print "Release 10.3.1-1.1, corresponding to Arm release 10.3-2021.07, was skipped."; print ""; print ":::"; next }1' "${to_path}" >"${to_path}.new" && mv -f "${to_path}.new" "${to_path}"

# convert qemu-arm admonition.
awk '/% include note.html content="The method to select the path/ { print ":::note"; print ""; print "The method to select the path based on the xPack version was already added to the Eclipse plug-in, but for now is only available in the version published on the test site (https://gnu-mcu-eclipse.netlify.com/v4-neon-updates-test/)."; print ""; print ":::"; next }1' "${to_path}" >"${to_path}.new" && mv -f "${to_path}.new" "${to_path}"

# convert qemu-arm admonition.
awk '/{% include warning.html content="In this old release/ { print ":::caution"; print ""; print "In this old release, support for hardware floating point on Cortex-M4 devices is not available."; print ""; print ":::"; next }1' "${to_path}" >"${to_path}.new" && mv -f "${to_path}.new" "${to_path}"

# convert windows-build-tools admonition.
awk '/{% include note.html content="In preparation for the xPack distribution,/ { print ":::note"; print ""; print "In preparation for the xPack distribution, only portable archives are provided; Windows setups are no longer supported."; print ""; print ":::"; next }1' "${to_path}" >"${to_path}.new" && mv -f "${to_path}.new" "${to_path}"

# convert windows-build-tools admonition.
awk '/{% include note.html content="By design, installing the xPack binaries/ { print ":::note"; print ""; print "By design, installing the xPack binaries does not require administrative rights, thus only portable archives are provided; Windows setups are no longer supported."; print ""; print ":::"; next }1' "${to_path}" >"${to_path}.new" && mv -f "${to_path}.new" "${to_path}"

# convert windows-build-tools admonition.
awk '/{% include warning.html content="This version is affected by the Windows UCRT bug/ { print ":::caution"; print ""; print "This version is affected by the Windows UCRT bug, `make` throws _Error -1073741819_; please use v4.3.x or later. Thank you for your understanding."; print ""; print ":::"; next }1' "${to_path}" >"${to_path}.new" && mv -f "${to_path}.new" "${to_path}"

# Remove from Easy install to Compliance.
if grep '### Easy install' "${to_path}" >/dev/null && grep '## Compliance' "${to_path}" >/dev/null
then
  awk '/## Compliance/ {print "--e-n-d-c-"; print; next }1' "${to_path}" >"${to_path}.new" && mv -f "${to_path}.new" "${to_path}"

  sed -i.bak -e '/^### Easy install$/,/^--e-n-d-c-$/d' "${to_path}"
fi

# Remove from ## Shared libraries to ## Documentation.
if grep '## Shared libraries' "${to_path}" >/dev/null && grep '## Documentation' "${to_path}" >/dev/null
then
  awk '/## Documentation/ { print "--e-n-d-s-"; print; next }1' "${to_path}" >"${to_path}.new" && mv -f "${to_path}.new" "${to_path}"

  sed -i.bak -e '/^## Shared libraries$/,/^--e-n-d-s-$/d' "${to_path}"
fi

# Change link to GitHub Releases to html to allow variables.
sed -i.bak -e 's|\[GitHub Releases\]... page.download_url ...|<a href={frontMatter.download_url}>GitHub Releases</a>|' "${to_path}"

# Change gcc links to html to allow variables.
sed -i.bak -e 's|\[{{ page.gcc_version }}\](https://gcc.gnu.org/gcc-{{ page.gcc_version_major }}/)|<a href={\`https://gcc.gnu.org/gcc-${frontMatter.gcc_version_major}\`}>{frontMatter.gcc_version}</a>|' "${to_path}"

# Change binutils links to html to allow variables.
sed -i.bak -e 's|\[{{ page.binutils_version }}\]({{ page.binutils_release_url }})|<a href={frontMatter.binutils_release_url}>{frontMatter.binutils_version}</a>|' "${to_path}"

# Change link to binary files to html to allow variables.
if grep -e 'Binary files .* page.download_url' "${to_path}" >/dev/null
then
  # awk '/Binary files .* page.download_url/ { print "<!-- truncate -->"; print ""; print; next }1' "${to_path}" >"${to_path}.new" && mv -f "${to_path}.new" "${to_path}"

  sed -i.bak -e 's|^.Binary files ..... page.download_url ...|<p><a href={frontMatter.download_url}>Binary files »</a></p>|' "${to_path}"
fi

# Fix RISC-V references to Install.
sed -i.bak -e 's|the separate \[How to install the RISC-V toolchain\?\].{{ site.baseurl }}/riscv-none-embed-gcc/install/. page.|the project [README](https://github.com/xpack-dev-tools/riscv-none-embed-gcc-xpack).|' "${to_path}"

sed -i.bak -e 's|separate .Install.... site.baseurl ../riscv-none-embed-gcc/install/. page.|project [README](https://github.com/xpack-dev-tools/riscv-none-embed-gcc-xpack).|' "${to_path}"

sed -i.bak -e 's|separate .Install.... site.baseurl ../dev-tools/riscv-none-elf-gcc/install/. page.|[Install Guide](/docs/install/).|' "${to_path}"

# Fix other references to Install.
sed -i.bak -e 's|separate \[.*\]... site.baseurl ../dev-tools/.*/install/) page|[Install Guide](/docs/install/)|' "${to_path}"
sed -i.bak -e 's|\[.*\]... site.baseurl ../dev-tools/.*/install/)|[Install Guide](/docs/install/)|' "${to_path}"

# Fix references to README-BUILD.md.
s="[Maintainer Info](/docs/maintainer/)"
sed -i.bak -e "s|.How to build..https://github.com/xpack-dev-tools/.*-xpack/blob/xpack/README-BUILD.md.|$s|" "${to_path}"

# Convert parametrised link to html.
sed -i.bak -e "s|.{{ page.upstream_commit }}..https://github.com/openocd-org/[a-z-]*/commit/{{ page.upstream_commit }}/)|<a href={\`https://github.com/openocd-org/${app_lc_name}/commit/\$\{frontMatter.upstream_commit}/\`}>{frontMatter.upstream_commit}</a>|" "${to_path}"

# Fix openocd documentation autolink.
sed -i.bak -e "s|- <https://openocd.org/doc/pdf/openocd.pdf>|- https://openocd.org/doc/pdf/openocd.pdf|" "${to_path}"

# Fix openocd code blocks.
s='/```sh/{N;N;s|```sh\n~/Library/xPacks/@xpack-dev-tools/openocd/{{ page.version }}.{{ page.npm_subversion }}/.content/bin/openocd -f board/stm32f4discovery.cfg\n```|<CodeBlock language="sh"> {\n`~/Library/xPacks/@xpack-dev-tools/openocd/${frontMatter.version}.${frontMatter.npm_subversion}/.content/bin/openocd -f board/stm32f4discovery.cfg`\n} </CodeBlock>|;}'
sed -i.bak -e "$s" "${to_path}"

s='/```sh/{N;s|```sh\n~/Library/xPacks/@xpack-dev-tools/openocd/{{ page.version }}.{{ page.npm_subversion }}/.content/bin/openocd -f board/stm32f4discovery.cfg|<CodeBlock language="console"> {\n`% ~/Library/xPacks/@xpack-dev-tools/openocd/${frontMatter.version}.${frontMatter.npm_subversion}/.content/bin/openocd -f board/stm32f4discovery.cfg|;}'
sed -i.bak -e "$s" "${to_path}"

s='/\^Cshutdown command invoked/{N;s|\^Cshutdown command invoked\n```|^Cshutdown command invoked`\n} </CodeBlock>|;}'
sed -i.bak -e "$s" "${to_path}"

# meson code sections
sed -i.bak -e 's|`lib/python{{ page.python_version }}`|<code>lib/python{frontMatter.python_version}</code>|' "${to_path}"
sed -i.bak -e 's|`lib/python{{ page.python_version }}/lib-dynload`|<code>lib/python{frontMatter.python_version}/lib-dynload</code>|' "${to_path}"
sed -i.bak -e 's|`lib/python{{ page.python_version }}/mesonbuild`|<code>lib/python{frontMatter.python_version}/mesonbuild</code>|' "${to_path}"
sed -i.bak -e 's|- .https://mesonbuild.com/Manual.html.(https://mesonbuild.com/Manual.html)|- https://mesonbuild.com/Manual.html|' "${to_path}"

# Preserve Eclipse variable syntax.
sed -i.bak -e 's|update the \`${openocd_path}\` variable|update the `$\\{openocd_path\\}` variable|' "${to_path}"

# Fix links to tests.
sed -i.bak -e "s|/dev-tools/${app_lc_name}/tests/|/docs/tests/|" "${to_path}"

# Fix qemu docs link
sed -i.bak -e 's|- <https://www.qemu.org/docs/master/>|- https://www.qemu.org/docs/master/|' "${to_path}"

# Fix wine docs link
sed -i.bak -e 's|- .https://www.winehq.org/documentation/.(https://www.winehq.org/documentation/)|- https://www.winehq.org/documentation/|' "${to_path}"

# Fix cmake docs link
sed -i.bak -e 's|- .https://cmake.org/documentation/.(https://cmake.org/documentation/)|- https://cmake.org/documentation/|' "${to_path}"

# Fix links to web sites.
sed -i.bak -e 's|\[xPack \(.*\)\][(]https://xpack.github.io/dev-tools/\([a-w].*\)/[)]|[xPack \1](https://xpack-dev-tools.github.io/\2-xpack/)|g' "${to_path}"
sed -i.bak -e 's|\[xPack \(.*\)\][(]https://xpack.github.io/\([a-w].*\)/[)]|[xPack \1](https://xpack-dev-tools.github.io/\2-xpack/)|g' "${to_path}"

# Fix project web path
sed -i.bak -e 's|https://xpack.github.io/dev-tools/\([a-z-]*\)/|https://xpack-dev-tools.github.io/\1-xpack|' "${to_path}"

# Replace `gcc-arm-none-eabi-{{ page.arm_version }}-src.tar.bz2`
sed -i.bak -e 's|`gcc-arm-none-eabi-..[ ]*page.arm_version[ ]*..-src.tar.bz2`|<code>gcc-arm-none-eabi-{frontMatter.arm_version}-src.tar.bz2</code>|g' "${to_path}"

# Replace `page.` with `frontMatter.` when using variables.
sed -i.bak -e 's|{{[ ]*page[.]\([a-z0-9_]*\)[ ]*}}|{frontMatter.\1}|g' "${to_path}"

# Fix local images url.
sed -i.bak -e 's|{{[ ]*site.baseurl[ ]*}}/assets/images|/img|g' "${to_path}"

# Fix link to tests results.
sed -i.bak -e 's|/dev-tools/gcc/|/docs/|g' "${to_path}"

# Remove QEMU link.
sed -i.bak -e 's|.GNU ARM Eclipse QEMU.({{ site.baseurl }}/dev-tools/qemu-arm/)|**GNU ARM Eclipse QEMU**|g' "${to_path}"

# Fix WBT platform.
sed -i.bak -e 's|There are separate binaries for ..Windows.. .Intel 32/64-bit.|There are binaries for **x64 Windows**|g' "${to_path}"

# Remove WBT link.
sed -i.bak -e 's|.Windows Build Tools..{{ site.baseurl }}/dev-tools/windows-build-tools/.|**Windows Build Tools**|g' "${to_path}"

# Fix WBT link.
sed -i.bak -e 's|please read the .dedicated page..{{ site.baseurl }}/dev-tools/windows-build-tools/.|please read the [Getting Started page](/docs/getting-started/)|g' "${to_path}"

# Fix platform names.
sed -i.bak -e "s|Intel 64-bit|x64|" "${to_path}"
sed -i.bak -e "s|Intel 32/64-bit|x64 and x86|" "${to_path}"
sed -i.bak -e "s|Apple Silicon 64-bit|arm64|" "${to_path}"
sed -i.bak -e "s|Arm 32/64-bit|arm64 and arm|" "${to_path}"

# Remove the `site.baseurl` from links.
sed -i.bak -e 's|{{ site.baseurl }}||g' "${to_path}"

# -----------------------------------------------------------------------------

# Squeeze multiple adjacent empty lines.
cat -s "${to_path}" >"${to_path}.new" && rm -f "${to_path}" && mv -f "${to_path}.new" "${to_path}"

rm -f "${to_path}.bak"
rm -f "${tmp_awk_file}"

# -----------------------------------------------------------------------------
