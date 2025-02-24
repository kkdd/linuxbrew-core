class Glooctl < Formula
  desc "Envoy-Powered API Gateway"
  homepage "https://docs.solo.io/gloo/latest/"
  url "https://github.com/solo-io/gloo.git",
      :tag      => "v1.3.20",
      :revision => "57e4bb83c0d13123b79a14b8536aad31c9d430a4"
  head "https://github.com/solo-io/gloo.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "8b2e2ffbaf9f9321168775a5e94976be2b2ca3aa02ecfb9c8088d11e5c3f9770" => :catalina
    sha256 "e2e32a1adea3e0762c8bcf74f3dbe506326a8323f566695c7a9a881c0eb99383" => :mojave
    sha256 "52a894d8cab2dda94036208afcc340ed7d75d25018a8fc5b5a6f77d7c1af4c56" => :high_sierra
    sha256 "c61cb57c8ec6bcf09c6fcbfeb8109dbe309efc5ef8a0a90fa0030e739536446e" => :x86_64_linux
  end

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    dir = buildpath/"src/github.com/solo-io/gloo"
    dir.install buildpath.children - [buildpath/".brew_home"]

    cd dir do
      system "make", "glooctl", "TAGGED_VERSION=v#{version}"
      bin.install "_output/glooctl"
    end
  end

  test do
    run_output = shell_output("#{bin}/glooctl 2>&1")
    assert_match "glooctl is the unified CLI for Gloo.", run_output

    version_output = shell_output("#{bin}/glooctl version 2>&1")
    assert_match "Client: {\"version\":\"#{version}\"}", version_output

    version_output = shell_output("#{bin}/glooctl version 2>&1")
    assert_match "Server: version undefined", version_output

    # Should error out as it needs access to a Kubernetes cluster to operate correctly
    status_output = shell_output("#{bin}/glooctl get proxy 2>&1", 1)
    assert_match "failed to create kube client", status_output
  end
end
