require 'package'

class Mesa < Package
  description 'Open-source implementation of the OpenGL specification'
  homepage 'https://www.mesa3d.org'
  # We use mesa amber (derived from the 21.3 series) for older kernels
  # and current mesa versions for newer kernels.
  if CREW_KERNEL_VERSION.to_f < 5.10
    # Built off of the mesa amber branch
    git_hashtag 'acfef002a081f36e6eebc6e8ab908a36ab18f68c'
    @_ver = git_hashtag[0, 7]
    version "amber-#{@_ver}"
  else
    @_ver = '22.3.0-rc3'
    version @_ver
    git_hashtag "mesa-#{@_ver}"
  end
  license 'MIT'
  compatibility 'all'
  source_url 'https://gitlab.freedesktop.org/mesa/mesa.git'

  if CREW_KERNEL_VERSION.to_f < 5.10
    binary_url({
      aarch64: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/mesa/amber-acfef00_armv7l/mesa-amber-acfef00-chromeos-armv7l.tar.zst',
       armv7l: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/mesa/amber-acfef00_armv7l/mesa-amber-acfef00-chromeos-armv7l.tar.zst',
         i686: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/mesa/amber-acfef00_i686/mesa-amber-acfef00-chromeos-i686.tar.zst',
       x86_64: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/mesa/amber-acfef00_x86_64/mesa-amber-acfef00-chromeos-x86_64.tar.zst'
    })
    binary_sha256({
      aarch64: 'e9ef6ce22956bdae6f75a44e953cc189f08a3c7e7cf9235a24dbe77f94dc39dd',
       armv7l: 'e9ef6ce22956bdae6f75a44e953cc189f08a3c7e7cf9235a24dbe77f94dc39dd',
         i686: '596ce6a08d3b63ba990058acdf876e4b815882e3d0e0c61bfcd079fdfeb6fb9f',
       x86_64: '9fe6dfd910312956da149dd5cd95f2fd58f7ca4bd8a4dbc646ec11ac3864a683'
    })
  else
    binary_url({
      aarch64: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/mesa/22.3.0-rc3_armv7l/mesa-22.3.0-rc3-chromeos-armv7l.tar.zst',
       armv7l: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/mesa/22.3.0-rc3_armv7l/mesa-22.3.0-rc3-chromeos-armv7l.tar.zst',
       x86_64: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/mesa/22.3.0-rc3_x86_64/mesa-22.3.0-rc3-chromeos-x86_64.tar.zst'
    })
    binary_sha256({
      aarch64: '2b509913bc66eb87b4794edb7739d3f57b00a0ea68b61f6d7e97ce8268c11465',
       armv7l: '2b509913bc66eb87b4794edb7739d3f57b00a0ea68b61f6d7e97ce8268c11465',
       x86_64: '02e83dff70b8b81f8c0d44659e6a63dfacb17faf4ebccde66c3c2bdaaff39473'
    })
  end

  depends_on 'elfutils' # R
  depends_on 'eudev' # R
  depends_on 'expat' # R
  depends_on 'gcc' # R
  depends_on 'glibc' # R
  depends_on 'glslang' => :build
  depends_on 'libdrm' # R
  depends_on 'libglvnd' # R
  depends_on 'libomxil_bellagio' => :build
  depends_on 'libunwind'
  depends_on 'libva' => :build # Enable only during build to avoid circular dep.
  depends_on 'libvdpau' => :build
  depends_on 'libx11' # R
  depends_on 'libxcb' # R
  depends_on 'libxdamage' => :build
  depends_on 'libxdmcp' => :build
  depends_on 'libxext' # R
  depends_on 'libxfixes' # R
  depends_on 'libxrandr' # R
  depends_on 'libxshmfence' # R
  depends_on 'libxv' => :build
  depends_on 'libxvmc' # R
  depends_on 'libxv' # R
  depends_on 'libxxf86vm' # R
  depends_on 'llvm' => :build
  depends_on 'lm_sensors' # R
  depends_on 'py3_mako'
  depends_on 'valgrind' => :build
  depends_on 'vulkan_headers' => :build
  depends_on 'vulkan_icd_loader' => :build
  depends_on 'vulkan_icd_loader' # R
  depends_on 'wayland_protocols' => :build
  depends_on 'wayland' # R
  depends_on 'zlibpkg' # R
  depends_on 'zstd' # R

  if CREW_KERNEL_VERSION.to_f < 5.10
    def self.patch
      case ARCH
      when 'aarch64', 'armv7l'
        # See https://gitlab.freedesktop.org/mesa/mesa/-/issues/5067
        @freedrenopatch = <<~FREEDRENOPATCHEOF
                  --- a/src/gallium/drivers/freedreno/freedreno_util.h   2021-08-05 14:40:22.000000000 +0000
                  +++ b/src/gallium/drivers/freedreno/freedreno_util.h   2021-08-05 19:52:53.115410668 +0000
                  @@ -44,6 +44,15 @@
                   #include "adreno_pm4.xml.h"
                   #include "disasm.h"
          #{'         '}
                  +#include <unistd.h>
                  +#include <sys/syscall.h>
                  +
                  +#ifndef SYS_gettid
                  +#error "SYS_gettid unavailable on this system"
                  +#endif
                  +
                  +#define gettid() ((pid_t)syscall(SYS_gettid))
                  +
                   #ifdef __cplusplus
                   extern "C" {
                   #endif
        FREEDRENOPATCHEOF
        File.write('freedreno.patch', @freedrenopatch)
        system 'patch -Np1 -i freedreno.patch'
        # See https://gitlab.freedesktop.org/mesa/mesa/-/issues/3505
        @tegrapatch = <<~TEGRAPATCHEOF
                  diff --git a/src/gallium/drivers/nouveau/nvc0/nvc0_state_validate.c b/src/gallium/drivers/nouveau/nvc0/nvc0_state_validate.c
                  index 48d81f197db..f9b7bd57b27 100644
                  --- a/src/gallium/drivers/nouveau/nvc0/nvc0_state_validate.c
                  +++ b/src/gallium/drivers/nouveau/nvc0/nvc0_state_validate.c
                  @@ -255,6 +255,10 @@ nvc0_validate_fb(struct nvc0_context *nvc0)
          #{'         '}
                            nvc0_resource_fence(res, NOUVEAU_BO_WR);
          #{'         '}
                  +         // hack to make opengl at least halfway working on a tegra k1
                  +         // see: https://gitlab.freedesktop.org/mesa/mesa/-/issues/3505#note_627006
                  +         fb->zsbuf=NULL;
                  +
                            assert(!fb->zsbuf);
                         }
        TEGRAPATCHEOF
        File.write('tegra.patch', @tegrapatch)
        system 'patch -Np1 -i tegra.patch'
      end
      # llvm 13/14 patch  See https://gitlab.freedesktop.org/mesa/mesa/-/issues/5455
      # & https://gitlab.freedesktop.org/mesa/mesa/-/merge_requests/13273.patch
      downloader 'https://gitlab.freedesktop.org/mesa/mesa/-/merge_requests/13273.diff',
                 '76d2dd16532336837bccd4885c40efed0ab5f1de8e8fa114a7835dc269f221ac'
      system 'patch -Np1 -i 13273.diff'
      # mesa: Implement ANGLE_sync_control_rate (used by Chrome browser)
      downloader 'https://gitlab.freedesktop.org/mesa/mesa/-/merge_requests/15381.diff',
                 '1391e189f5ad40a711a6f72a7d59aef1b943ec9dc408852f5f562699bf50ba6c'
      system 'patch -Np1 -i 15381.diff'
      # llvm 15 patch
      puts 'patch 1'
      downloader 'https://gitlab.freedesktop.org/mesa/mesa/-/merge_requests/15091.diff',
                 'c53387c9fce1f34b6d7c0272ebef148dda59dea35fd83df2f3f4a0033732ebbd'
      system 'patch -Np1 -i 15091.diff'
      # another llvm 15 patch
      downloader 'https://gitlab.freedesktop.org/mesa/mesa/-/merge_requests/15232.diff',
                 'c66b6b03a59ad43a89bc7ab4e04f8c311631d27c3ea6769217c09beef707d6c3'
      system 'patch -Np1 -i 15232.diff'
      # another llvm 15 patch
      puts 'patch 3'
      downloader 'https://gitlab.freedesktop.org/mesa/mesa/-/merge_requests/16129.diff',
                 '88e5d7f6b4e6dd4ac7220cf194aab6e86d748a8cb99a86515eb4c6bdf9b20959'
      system 'patch -Np1 -i 16129.diff'
      # another llvm 15 patch
      puts 'patch 4'
      # downloader 'https://gitlab.freedesktop.org/mesa/mesa/-/merge_requests/16289.diff',
      #            '56725f4238d8bb60d813db1724e37bf149345ff456c0c2792f0982d237c18cf1'
      system 'curl -OLf https://gitlab.freedesktop.org/mesa/mesa/-/merge_requests/16289.diff'
      puts 'installing patch 4'
      system 'patch -Np1 -F 10  -i 16289.diff'
      # another llvm 15 patch
      puts 'patch 5'
      # downloader 'https://gitlab.freedesktop.org/mesa/mesa/-/merge_requests/17514.diff',
      #            'b769f0eb2db0b71723f8ad6f20c03a166a54eab74bfd292cf5b9c8ea86d2c73b'
      system 'curl -OLf https://gitlab.freedesktop.org/mesa/mesa/-/merge_requests/17514.diff'
      system 'patch -Np1 -i 17514.diff'
      puts 'downloader done'
      # another llvm 15 patch
      # Refreshed patch from https://gitlab.freedesktop.org/mesa/mesa/-/merge_requests/17518.diff
      @mesa_patch = <<~'PATCH_EOF'
        diff -Npaur a/lp_bld_arit.c b/lp_bld_arit.c
        --- a/src/gallium/auxiliary/gallivm/lp_bld_arit.c
        +++ b/src/gallium/auxiliary/gallivm/lp_bld_arit.c
        @@ -391,16 +391,10 @@ lp_build_comp(struct lp_build_context *b
                  return LLVMBuildNot(builder, a, "");
            }

        -   if(LLVMIsConstant(a))
        -      if (type.floating)
        -          return LLVMConstFSub(bld->one, a);
        -      else
        -          return LLVMConstSub(bld->one, a);
        +   if (type.floating)
        +      return LLVMBuildFSub(builder, bld->one, a, "");
            else
        -      if (type.floating)
        -         return LLVMBuildFSub(builder, bld->one, a, "");
        -      else
        -         return LLVMBuildSub(builder, bld->one, a, "");
        +      return LLVMBuildSub(builder, bld->one, a, "");
         }


        @@ -479,16 +473,10 @@ lp_build_add(struct lp_build_context *bl
               }
            }

        -   if(LLVMIsConstant(a) && LLVMIsConstant(b))
        -      if (type.floating)
        -         res = LLVMConstFAdd(a, b);
        -      else
        -         res = LLVMConstAdd(a, b);
        +   if (type.floating)
        +      res = LLVMBuildFAdd(builder, a, b, "");
            else
        -      if (type.floating)
        -         res = LLVMBuildFAdd(builder, a, b, "");
        -      else
        -         res = LLVMBuildAdd(builder, a, b, "");
        +      res = LLVMBuildAdd(builder, a, b, "");

            /* clamp to ceiling of 1.0 */
            if(bld->type.norm && (bld->type.floating || bld->type.fixed))
        @@ -815,16 +803,10 @@ lp_build_sub(struct lp_build_context *bl
               }
            }

        -   if(LLVMIsConstant(a) && LLVMIsConstant(b))
        -      if (type.floating)
        -         res = LLVMConstFSub(a, b);
        -      else
        -         res = LLVMConstSub(a, b);
        +   if (type.floating)
        +      res = LLVMBuildFSub(builder, a, b, "");
            else
        -      if (type.floating)
        -         res = LLVMBuildFSub(builder, a, b, "");
        -      else
        -         res = LLVMBuildSub(builder, a, b, "");
        +      res = LLVMBuildSub(builder, a, b, "");

            if(bld->type.norm && (bld->type.floating || bld->type.fixed))
               res = lp_build_max_simple(bld, res, bld->zero, GALLIVM_NAN_RETURN_OTHER_SECOND_NONNAN);
        @@ -980,29 +962,15 @@ lp_build_mul(struct lp_build_context *bl
            else
               shift = NULL;

        -   if(LLVMIsConstant(a) && LLVMIsConstant(b)) {
        -      if (type.floating)
        -         res = LLVMConstFMul(a, b);
        -      else
        -         res = LLVMConstMul(a, b);
        -      if(shift) {
        -         if(type.sign)
        -            res = LLVMConstAShr(res, shift);
        -         else
        -            res = LLVMConstLShr(res, shift);
        -      }
        -   }
        -   else {
        -      if (type.floating)
        -         res = LLVMBuildFMul(builder, a, b, "");
        +   if (type.floating)
        +       res = LLVMBuildFMul(builder, a, b, "");
        +    else
        +       res = LLVMBuildMul(builder, a, b, "");
        +    if (shift) {
        +       if (type.sign)
        +          res = LLVMBuildAShr(builder, res, shift, "");
               else
        -         res = LLVMBuildMul(builder, a, b, "");
        -      if(shift) {
        -         if(type.sign)
        -            res = LLVMBuildAShr(builder, res, shift, "");
        -         else
        -            res = LLVMBuildLShr(builder, res, shift, "");
        -      }
        +          res = LLVMBuildLShr(builder, res, shift, "");
            }

            return res;
        @@ -1288,15 +1256,6 @@ lp_build_div(struct lp_build_context *bl
            if(a == bld->undef || b == bld->undef)
               return bld->undef;

        -   if(LLVMIsConstant(a) && LLVMIsConstant(b)) {
        -      if (type.floating)
        -         return LLVMConstFDiv(a, b);
        -      else if (type.sign)
        -         return LLVMConstSDiv(a, b);
        -      else
        -         return LLVMConstUDiv(a, b);
        -   }
        -
            /* fast rcp is disabled (just uses div), so makes no sense to try that */
            if(FALSE &&
               ((util_get_cpu_caps()->has_sse && type.width == 32 && type.length == 4) ||
        @@ -2643,7 +2602,7 @@ lp_build_rcp(struct lp_build_context *bl
            assert(type.floating);

            if(LLVMIsConstant(a))
        -      return LLVMConstFDiv(bld->one, a);
        +      return LLVMBuildFDiv(builder, bld->one, a, "");

            /*
             * We don't use RCPPS because:

      PATCH_EOF
      File.write('mesa.patch', @mesa_patch)
      system 'patch -p1 -i mesa.patch'
    end

    def self.build
      case ARCH
      when 'i686'
        @vk = 'intel,swrast'
        @galliumdrivers = 'swrast,svga,virgl,zink'
        @lto = CREW_MESON_FNO_LTO_OPTIONS
        @osmesa = 'false'
      when 'aarch64', 'armv7l'
        @vk = 'auto'
        @galliumdrivers = 'auto'
        @lto = CREW_MESON_OPTIONS
        @osmesa = 'true'
      when 'x86_64'
        @vk = 'auto'
        @galliumdrivers = 'r300,r600,radeonsi,nouveau,virgl,svga,swrast,iris,crocus'
        @lto = CREW_MESON_OPTIONS
        @osmesa = 'true'
      end
      system "meson #{@lto} \
      -Db_asneeded=false \
      -Ddri-drivers=auto \
      -Dvulkan-drivers=#{@vk} \
      -Dgallium-drivers=#{@galliumdrivers} \
      -Dosmesa=#{@osmesa} \
      -Dglvnd=true \
       builddir"
      system 'meson configure builddir'
      system 'mold -run samu -C builddir'
    end
  else
    def self.build
      system "meson setup #{CREW_MESON_OPTIONS} \
      -Db_asneeded=false \
      -Ddri3=enabled \
      -Degl=enabled \
      -Dgbm=enabled \
      -Dgles1=disabled \
      -Dgles2=enabled \
      -Dglvnd=true \
      -Dglx=dri \
      -Dllvm=enabled \
      -Dvulkan-drivers=auto \
      -Dvideo-codecs='vc1dec,h264dec,h264enc,h265dec,h265enc' \
       builddir"
      system 'meson configure builddir'
      system 'mold -run samu -C builddir'
    end
  end

  def self.install
    system "DESTDIR=#{CREW_DEST_DIR} samu -C builddir install"
    # The following are hacks to keep sommelier from complaining.
    Dir.chdir("#{CREW_DEST_LIB_PREFIX}/dri") do
      FileUtils.ln_s '.', 'tls' unless File.exist?('tls')
    end
    FileUtils.mkdir_p "#{CREW_DEST_LIB_PREFIX}/gbm/tls"
    case ARCH
    when 'x86_64', 'i686'
      Dir.chdir("#{CREW_DEST_LIB_PREFIX}/gbm/tls") do
        # For Intel GPUs
        FileUtils.ln_s '../../libgbm.so', 'i915_gbm.so'
        # For AMD GPUs
        FileUtils.ln_s '../../libgbm.so', 'amdgpu_gbm.so'
      end
    when 'armv7l', 'aarch64'
      Dir.chdir("#{CREW_DEST_LIB_PREFIX}/gbm/tls") do
        FileUtils.ln_s '../../libgbm.so', 'pvr_gbm.so'
      end
    end
  end
end
