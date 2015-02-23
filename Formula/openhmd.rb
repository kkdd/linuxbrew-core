class Openhmd < Formula
  homepage "http://openhmd.net"
  url "http://openhmd.net/releases/openhmd-0.1.0.tar.gz"
  sha1 "186c747399bd9a509ac8300acbae8823fc4fcc79"

  bottle do
    cellar :any
    sha1 "dac2183e6b2b3e63d8046204fadc727db1eaab3a" => :yosemite
    sha1 "4e7dcfa3ed6f521d908859251d3e6552e8aa70a2" => :mavericks
    sha1 "d72136368a6c671711c9a135d4b256813e06c755" => :mountain_lion
  end

  head do
    url "https://github.com/OpenHMD/OpenHMD.git"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "hidapi"

  def install
    args = ["--prefix", prefix,
            "--disable-debug",
            "--disable-silent-rules",
            "--disable-dependency-tracking",
            "--bindir=#{bin}"]

    system "./autogen.sh" if build.head?
    system "./configure", *args
    system "make", "install"
    (share+"tests").install "#{bin}/unittests"
  end

  test do
    system "#{share}/tests/unittests"
  end
end
