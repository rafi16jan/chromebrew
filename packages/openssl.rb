require 'package'

class Openssl < Package
  description 'The Open Source toolkit for Secure Sockets Layer and Transport Layer Security'
  homepage 'https://www.openssl.org'
  version '3.0.13' # Do not use @_ver here, it will break the installer.
  license 'Apache-2.0'
  compatibility 'all'
  source_url 'https://www.openssl.org/source/openssl-3.0.13.tar.gz'
  source_sha256 '88525753f79d3bec27d2fa7c66aa0b92b3aa9498dafd93d7cfa4b3780cdae313'
  binary_compression 'tar.zst'

  binary_sha256({
    aarch64: '5450b693d453d48b4c4e0c594c98e9bb684a316802b7540cee2e52278a0d61d6',
     armv7l: '5450b693d453d48b4c4e0c594c98e9bb684a316802b7540cee2e52278a0d61d6',
       i686: 'a3e19ddaee80131c3432bca1acba02b095af9656d80a509e3584370f8ad7e4f4',
     x86_64: '8ee844ac6718027da140b25501f9c2676eb98c741b0256c4c5d24b32b0b9999a'
  })

  depends_on 'ccache' => :build
  depends_on 'glibc' # R

  case ARCH
  when 'aarch64', 'armv7l'
    @arch_c_flags = '-fPIC -march=armv7-a -mfloat-abi=hard -fuse-ld=mold'
    @arch_cxx_flags = '-fPIC -march=armv7-a -mfloat-abi=hard -fuse-ld=mold'
    @openssl_configure_target = 'linux-generic32'
  when 'i686'
    @arch_c_flags = '-fPIC -fuse-ld=mold'
    @arch_cxx_flags = '-fPIC -fuse-ld=mold'
    @openssl_configure_target = 'linux-x86'
  when 'x86_64'
    @arch_c_flags = '-fPIC -fuse-ld=mold'
    @arch_cxx_flags = '-fPIC -fuse-ld=mold'
    @openssl_configure_target = 'linux-x86_64'
  end
  @ARCH_LDFLAGS = '-flto'
  @ARCH_C_LTO_FLAGS = "#{@arch_c_flags} -flto=auto"
  @ARCH_CXX_LTO_FLAGS = "#{@arch_cxx_flags} -flto=auto"

  def self.build
    @no_tests_target = `openssl version | awk '{print $2}'`.chomp == version.to_s ? 'no-tests' : ''

    # This gives you the list of OpenSSL configure targets
    system './Configure LIST'
    system "PATH=#{CREW_LIB_PREFIX}/ccache/bin:#{CREW_PREFIX}/bin:/usr/bin:/bin \
      CFLAGS=\"#{@ARCH_C_LTO_FLAGS}\" CXXFLAGS=\"#{@ARCH_CXX_LTO_FLAGS}\" \
      LDFLAGS=\"#{@ARCH_LDFLAGS}\" \
      mold -run ./Configure --prefix=#{CREW_PREFIX} \
      --libdir=#{CREW_LIB_PREFIX} \
      --openssldir=#{CREW_PREFIX}/etc/ssl \
      #{@openssl_configure_target} #{@no_tests_target}"
    system 'make'
  end

  def self.check
    # ecdsatest fails on i686
    # collect2: fatal error: ld terminated with signal 11 [Segmentation fault], core dumped
    # http_test fails on x86_64
    # collect2: error: ld returned 127 exit status
    return if ARCH == 'i686' || ARCH == 'x86_64'

    # Don't run tests if we are just rebuilding the same version of openssl.
    system 'make test' unless `openssl version | awk '{print $2}'`.chomp == version.to_s
  end

  def self.install
    system "make DESTDIR=#{CREW_DEST_DIR} install_sw install_ssldirs"
    # Extract OpenSSL 1.1.1 libraries for backwards compatibility purposes
    # from the openssl111 package.
    # Builds and rebuilds of packages against OpenSSL should automatically
    # build against OpenSSL 3.x and not against OpenSSL 1.1.1x.
    File.write 'openssl111_files', <<~EOF
      #{CREW_LIB_PREFIX[1..]}/libcrypto.so.1.1
      #{CREW_LIB_PREFIX[1..]}/libssl.so.1.1
    EOF
    @cur_dir = Dir.pwd
    @legacy_version = '1.1.1w'
    case ARCH
    when 'aarch64', 'armv7l'
      downloader "https://gitlab.com/api/v4/projects/26210301/packages/generic/openssl111/#{@legacy_version}_armv7l/openssl111-#{@legacy_version}-chromeos-armv7l.tar.zst",
                 '650209f527994f5c8bd57d1f2b5c42174d66472ca2a40116f66a043bd6e4c046', "openssl111-#{@legacy_version}-chromeos.tar.zst"
    when 'i686'
      downloader "https://gitlab.com/api/v4/projects/26210301/packages/generic/openssl111/#{@legacy_version}_i686/openssl111-#{@legacy_version}-chromeos-i686.tar.zst",
                 'a409ebebe5b5789e3ed739bc540d150faa66d9e33e6f19000b1b4e110a86d618', "openssl111-#{@legacy_version}-chromeos.tar.zst"
    when 'x86_64'
      downloader "https://gitlab.com/api/v4/projects/26210301/packages/generic/openssl111/#{@legacy_version}_x86_64/openssl111-#{@legacy_version}-chromeos-x86_64.tar.zst",
                 'e95e8cf456fc9168de148946c38cdda6a1e7482bdcbb4121766a178a32421917', "openssl111-#{@legacy_version}-chromeos.tar.zst"
    end
    Dir.chdir(CREW_DEST_DIR) do
      system "tar -Izstd -xv --files-from #{@cur_dir}/openssl111_files -f #{@cur_dir}/openssl111-#{@legacy_version}-chromeos.tar.zst"
    end
  end
end
