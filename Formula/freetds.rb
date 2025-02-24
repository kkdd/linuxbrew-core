class Freetds < Formula
  desc "Libraries to talk to Microsoft SQL Server and Sybase databases"
  homepage "https://www.freetds.org/"
  url "https://www.freetds.org/files/stable/freetds-1.1.32.tar.gz"
  sha256 "8f73036a5f0fdfaa6504ccd67f06332f1329531ff106308cc2453a69368d1ed8"

  bottle do
    sha256 "3c8fff5ab322a7188930d4ce77d391cbc817f6ffec63d9cf4d0028102fb0d0b4" => :catalina
    sha256 "a03cf2ea11087d9c04f19ae7d2f4c1d754662ed5d9e8d607570da3153cd2b77c" => :mojave
    sha256 "97814a74645674382d92cfc4a787d22a4766f89321fb75b1df3b0f490d66634b" => :high_sierra
    sha256 "c3cc55fd6b64764264bab78708de89ae64930af87a3103db94ea170587e5a1e2" => :x86_64_linux
  end

  head do
    url "https://github.com/FreeTDS/freetds.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "gettext" => :build
    depends_on "libtool" => :build
  end

  depends_on "pkg-config" => :build
  depends_on "openssl@1.1"
  depends_on "unixodbc"

  depends_on "readline" unless OS.mac?

  def install
    args = %W[
      --prefix=#{prefix}
      --with-tdsver=7.3
      --mandir=#{man}
      --sysconfdir=#{etc}
      --with-unixodbc=#{Formula["unixodbc"].opt_prefix}
      --with-openssl=#{Formula["openssl@1.1"].opt_prefix}
      --enable-sybase-compat
      --enable-krb5
      --enable-odbc-wide
    ]

    if build.head?
      system "./autogen.sh", *args
    else
      system "./configure", *args
    end
    system "make"
    ENV.deparallelize # Or fails to install on multi-core machines
    system "make", "install"
  end

  test do
    system "#{bin}/tsql", "-C"
  end
end
