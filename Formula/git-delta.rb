class GitDelta < Formula
  desc "Syntax-highlighting pager for git and diff output"
  homepage "https://github.com/dandavison/delta"
  url "https://github.com/dandavison/delta/archive/0.0.17.tar.gz"
  sha256 "ac1f26ac5ea10d43b300675189c49437dcae7a9fca7e51f615058ab0550d27e5"
  head "https://github.com/dandavison/delta.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "bd34af46b5fbe439c7b750700147c1a8dce7d4f1977ba98703874ac44da54d63" => :catalina
    sha256 "0a591211906c5c1e847e8352ccf479a761e90592c3cb4df49cfd3371a777486c" => :mojave
    sha256 "28071a294f904583d609b6a25156ec1d8b5812cac30fe9ae8bd004c7e230254c" => :high_sierra
    sha256 "9e745bbe9b0b32210b0d774d6211a1cef781cf68a431ac903314d77ede9b2737" => :x86_64_linux
  end

  depends_on "rust" => :build
  depends_on "llvm" => :build unless OS.mac?

  conflicts_with "delta", :because => "both install a `delta` binary"

  def install
    ENV.append_to_cflags "-fno-stack-check" if DevelopmentTools.clang_build_version >= 1010
    system "cargo", "install", "--locked", "--root", prefix, "--path", "."
  end

  test do
    assert_match "delta #{version}", `#{bin}/delta --version`.chomp
  end
end
