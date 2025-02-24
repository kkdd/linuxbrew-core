class Helmsman < Formula
  desc "Helm Charts as Code tool"
  homepage "https://github.com/Praqma/helmsman"
  url "https://github.com/Praqma/helmsman.git",
    :tag      => "v3.2.0",
    :revision => "63a52dc33f99416593758fb2384e150607254885"

  bottle do
    cellar :any_skip_relocation
    sha256 "45c6b2e67dc49fd14e710ca2108d9a56d81bd5066b64784faa644f19aa3d9f0d" => :catalina
    sha256 "25444ffe3230b9a712f6a675cdd27b29df50b77997348df618bc9459c8a8cfa8" => :mojave
    sha256 "4f4eb591ee46097d1b949fd38c03643f60a43267248d0c4b2476db1aba563c90" => :high_sierra
    sha256 "eadef370b84e79ae1a5e9d61cd27eaafba74ef960c13ceb246c50c35793f1c0f" => :x86_64_linux
  end

  depends_on "go" => :build
  depends_on "helm"
  depends_on "kubernetes-cli"

  def install
    system "go", "build",
      "-ldflags", "-s -w -X main.version=#{version}",
      "-trimpath", "-o", bin/"helmsman", "cmd/helmsman/main.go"
    prefix.install_metafiles
    pkgshare.install "examples/example.yaml"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/helmsman version")

    output = shell_output("#{bin}/helmsman --apply -f #{pkgshare}/example.yaml 2>&1", 1)
    assert_match "helm diff plugin is not installed", output
  end
end
