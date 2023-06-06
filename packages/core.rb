require 'package'

class Core < Package
  description 'Core Chromebrew Packages.'
  homepage 'https://github.com/chromebrew/chromebrew'
  version '1.8'
  license 'GPL-3+'
  compatibility 'all'

  is_fake

  depends_on 'brotli'
  depends_on 'bz2'
  depends_on 'c_ares'
  depends_on 'ca_certificates'
  depends_on 'crew_mvdir'
  depends_on 'crew_profile_base'
  depends_on 'e2fsprogs'
  depends_on 'elfutils'
  depends_on 'expat'
  depends_on 'filecmd'
  depends_on 'flex'
  depends_on 'gcc_lib'
  depends_on 'gdbm'
  depends_on 'gettext'
  depends_on 'git'
  depends_on 'glibc'
  depends_on 'gmp'
  depends_on 'gnutls'
  depends_on 'groff'
  depends_on 'icu4c'
  depends_on 'krb5'
  depends_on 'less'
  depends_on 'libarchive'
  depends_on 'libcyrussasl'
  depends_on 'libdb'
  depends_on 'libedit'
  depends_on 'libffi'
  depends_on 'libidn2'
  depends_on 'libmetalink'
  depends_on 'libnghttp2'
  depends_on 'libpipeline'
  depends_on 'libpsl'
  depends_on 'libseccomp'
  depends_on 'libsigsegv'
  depends_on 'libssp'
  depends_on 'libtasn1'
  depends_on 'libtirpc'
  depends_on 'libunbound'
  depends_on 'libunistring'
  depends_on 'libxml2'
  depends_on 'libyaml'
  depends_on 'lz4'
  depends_on 'lzip'
  depends_on 'm4'
  depends_on 'mandb'
  depends_on 'manpages'
  depends_on 'mawk'
  depends_on 'most'
  depends_on 'ncurses'
  depends_on 'nettle'
  depends_on 'openldap'
  depends_on 'openssl'
  depends_on 'patchelf'
  depends_on 'p11kit'
  depends_on 'pcre'
  depends_on 'pcre2'
  depends_on 'perl'
  depends_on 'pixz'
  depends_on 'popt'
  depends_on 'py3_wheel'
  depends_on 'python3'
  depends_on 'readline'
  depends_on 'rtmpdump'
  depends_on 'ruby'
  depends_on 'slang'
  depends_on 'sqlite'
  depends_on 'uchardet'
  depends_on 'unzip'
  depends_on 'xzutils'
  depends_on 'xxhash'
  depends_on 'zip'
  depends_on 'zlibpkg'
  depends_on 'zstd'
end
