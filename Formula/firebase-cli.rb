require "language/node"

class FirebaseCli < Formula
  desc "Firebase command-line tools"
  homepage "https://firebase.google.com/docs/cli/"
  url "https://registry.npmjs.org/firebase-tools/-/firebase-tools-8.0.3.tgz"
  sha256 "4605244f0e6ba7d6b9b034e662c3e086a77ed5f297c343d63c073b56c1e8c69a"
  head "https://github.com/firebase/firebase-tools.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "8d739b52b2d6033f43311288312f453f264a3042413777c352fe04edc6c574ad" => :catalina
    sha256 "2472d811c8d102cbcf55f0608ad9e23921f85e1fa22ac9bae55ff7c11ac35ebc" => :mojave
    sha256 "73ca37bf1954f1c136b0813f870695a66ee1d8fa089875adcb2da47052f1e6c7" => :high_sierra
    sha256 "0a0e41db95c409ff26dfda26e34e4d7776f8de55dd6c5bea30523aa4ff6b64f2" => :x86_64_linux
  end

  depends_on "node"

  uses_from_macos "expect" => :test

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    (testpath/"test.exp").write <<~EOS
      spawn #{bin}/firebase login:ci --no-localhost
      expect "Paste"
    EOS
    assert_match "authorization code", shell_output("expect -f test.exp")
  end
end
