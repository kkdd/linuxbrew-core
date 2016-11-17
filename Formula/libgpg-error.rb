class LibgpgError < Formula
  desc "Common error values for all GnuPG components"
  homepage "https://www.gnupg.org/related_software/libgpg-error/"
  url "https://gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-1.25.tar.bz2"
  mirror "https://mirrors.ocf.berkeley.edu/debian/pool/main/libg/libgpg-error/libgpg-error_1.25.orig.tar.bz2"
  sha256 "f628f75843433b38b05af248121beb7db5bd54bb2106f384edac39934261320c"

  bottle do
    cellar :any
    sha256 "7e24a4a8c5d6ba2a6834d8ebbef72f2d76d795ee8b349b6560d2058af1e46d1c" => :sierra
    sha256 "4a8ddf89b1502ed14a165b834c95aefb0bb519f23cbfc3d7212524dd301ff3be" => :el_capitan
    sha256 "a06c5094fb9ebf5e4069672d0c83a98fb695f59748c59051df20b3d776f71f3b" => :yosemite
    sha256 "44d4ca69136518bddf81d6e2d1cadc7191e5b0b384d37f47e08f39e5e0121d7d" => :mavericks
  end

  option :universal

  def install
    ENV.universal_binary if build.universal?

    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--enable-static"
    system "make", "install"

    # avoid triggering mandatory rebuilds of software that hard-codes this path
    inreplace bin/"gpg-error-config", prefix, opt_prefix
  end

  test do
    system "#{bin}/gpg-error-config", "--libs"
  end
end
