class Helmfile < Formula
  desc "Deploy Kubernetes Helm Charts"
  homepage "https://github.com/roboll/helmfile"
  url "https://github.com/roboll/helmfile/archive/v0.109.0.tar.gz"
  sha256 "ab4a444fc305cfd1d2447eeb94cfee3c60f46815b4301db68d02703be12a2a8e"

  bottle do
    cellar :any_skip_relocation
    sha256 "192ca3a0d359af493ba125b27251a3b5a364b9b5431b43158906f578bd7e56e7" => :catalina
    sha256 "01a27d2ecbb38bbcbb17c7f3b9212537d4be4f0ed1fe354f3770f13ea64f62b4" => :mojave
    sha256 "e55c9d27414807f06a593080d817df4aebce9e7d075873c0b94f5d717ba9a656" => :high_sierra
    sha256 "4857c7c91739fb4bd8a2596f57fcfa6a217d90534c27165db9d01c5ed132b404" => :x86_64_linux
  end

  depends_on "go" => :build
  depends_on "helm"

  def install
    system "go", "build", "-ldflags", "-X github.com/roboll/helmfile/pkg/app/version.Version=v#{version}",
             "-o", bin/"helmfile", "-v", "github.com/roboll/helmfile"
  end

  test do
    (testpath/"helmfile.yaml").write <<-EOS
    repositories:
    - name: stable
      url: https://kubernetes-charts.storage.googleapis.com/

    releases:
    - name: vault                            # name of this release
      namespace: vault                       # target namespace
      labels:                                # Arbitrary key value pairs for filtering releases
        foo: bar
      chart: roboll/vault-secret-manager     # the chart being installed to create this release, referenced by `repository/chart` syntax
      version: ~1.24.1                       # the semver of the chart. range constraint is supported
    EOS
    system Formula["helm"].opt_bin/"helm", "create", "foo"
    output = "Adding repo stable https://kubernetes-charts.storage.googleapis.com"
    assert_match output, shell_output("#{bin}/helmfile -f helmfile.yaml repos 2>&1")
    assert_match version.to_s, shell_output("#{bin}/helmfile -v")
  end
end
