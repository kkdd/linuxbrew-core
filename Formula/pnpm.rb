class Pnpm < Formula
  require "language/node"

  desc "📦🚀 Fast, disk space efficient package manager"
  homepage "https://pnpm.js.org"
  url "https://registry.npmjs.org/pnpm/-/pnpm-4.13.0.tgz"
  sha256 "f1903ce194095b45f64974497a5bc0c02a6741afbc309045c13b55c30bbf59f3"

  bottle do
    cellar :any_skip_relocation
    sha256 "a5ac85a98e261ff079f4cd63bc55f748a3874324e729fddee99016b7c520b8a7" => :catalina
    sha256 "5a037a86abe98a05f6e32ac0d707254513c170fec90f1d0026658854a781ec16" => :mojave
    sha256 "e352b051de06c30c230f655e6a6693b17c96ebbb6de9be432f79e121d955fd77" => :high_sierra
    sha256 "34c0fec844191b62fe927e0a11a7c30344dbec851cd71c148b8dd16f84e070db" => :x86_64_linux
  end

  depends_on "node"

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    system "#{bin}/pnpm", "init", "-y"
    assert_predicate testpath/"package.json", :exist?, "package.json must exist"
  end
end
