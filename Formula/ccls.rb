class Ccls < Formula
  desc "C/C++/ObjC language server"
  homepage "https://github.com/MaskRay/ccls"
  url "https://github.com/MaskRay/ccls/archive/0.20190823.5.tar.gz"
  sha256 "6f39fa5ce79c1682973811ce2409718710bfef6008f94f96277393e6846bd76c"
  head "https://github.com/MaskRay/ccls.git"

  bottle do
    sha256 "5f5f3e9a71c2b2ba7362ea9f6d725f0a86385ed76faefabe2ce1e8060f40d949" => :catalina
    sha256 "cd9e2218ba5994b9c8d8a03f53f48e4060f5f521edd7c692ff07907deef6fec3" => :mojave
    sha256 "5dfe79e4ec483f78779750ac47405d53e75215d60bb9b326ce0397e14723f048" => :high_sierra
    sha256 "164c14021c5985b055227a0893403e7b3f6398dc676b7b8fdf88db87121e899c" => :x86_64_linux
  end

  depends_on "cmake" => :build
  depends_on "rapidjson" => :build
  depends_on "llvm"
  depends_on :macos => :high_sierra # C++ 17 is required
  depends_on "gcc@9" unless OS.mac? # C++17 is required

  fails_with :gcc => "4"
  fails_with :gcc => "5"
  fails_with :gcc => "6"
  fails_with :gcc => "7" do
    version "7.1"
  end

  def install
    # https://github.com/Homebrew/brew/issues/6070
    unless OS.mac?
      ENV.remove %w[LDFLAGS LIBRARY_PATH HOMEBREW_LIBRARY_PATHS], "#{HOMEBREW_PREFIX}/lib"
    end

    system "cmake", *std_cmake_args
    system "make", "install"
  end

  test do
    system bin/"ccls", "-index=#{testpath}"
  end
end
