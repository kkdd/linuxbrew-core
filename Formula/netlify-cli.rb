require "language/node"

class NetlifyCli < Formula
  desc "Netlify command-line tool"
  homepage "https://www.netlify.com/docs/cli"
  url "https://registry.npmjs.org/netlify-cli/-/netlify-cli-2.46.0.tgz"
  sha256 "5e9f257d66f9b02ef7e100b30500c9027fd54adb3b86834a7440a98cefcc4705"
  head "https://github.com/netlify/cli.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "97dd13f9fe9d6dbc1e86a59caab19d3d3ff6c900851bcda44dd87ecb754a2f5f" => :catalina
    sha256 "60d235d77be3c2aea2e592ef70703b14e4707cdf8a8717f897a6a26cd1eeb038" => :mojave
    sha256 "fffbc06a00ccec4678bc8b5a21b22dc8c5856e5ecca0bff671cbdf7c4ec70397" => :high_sierra
    sha256 "b4b334f01531b2bd49648aab89f660b893922a4f9d15cf1a60f3bc24566dded1" => :x86_64_linux
  end

  depends_on "node"

  uses_from_macos "expect" => :test

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    (testpath/"test.exp").write <<~EOS
      spawn #{bin}/netlify login
      expect "Opening"
    EOS
    assert_match "Logging in", shell_output("expect -f test.exp")
  end
end
