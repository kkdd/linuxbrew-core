class Diffoscope < Formula
  include Language::Python::Virtualenv

  desc "In-depth comparison of files, archives, and directories"
  homepage "https://diffoscope.org"
  url "https://files.pythonhosted.org/packages/ea/cd/7561630bcdbec196b09aea0a331e538839cd0a002f603057ebea7ab75f81/diffoscope-140.tar.gz"
  sha256 "0df96f51d1d3e698c27ea5aa6507e50857c15c41414d506bed7f45c56dd7cef7"

  bottle do
    cellar :any_skip_relocation
    sha256 "8b9ba74962870f776d80eb06bbdd87bffbb38cb6846b87798e5c98c686dff57e" => :catalina
    sha256 "a5b59fc33ad10ac055a621983cc95e96b8beab11d0d15e630098d3944245a950" => :mojave
    sha256 "9c29cc90c11d523607566059fc01092abbf80cd66cfc70c32c8dac9c23bdafe4" => :high_sierra
    sha256 "47cd4d211f19e76d730df1c9e2d84894e5acbc2b2c055c5a2f5076ae691a9bb6" => :x86_64_linux
  end

  depends_on "gnu-tar"
  depends_on "libarchive"
  depends_on "libmagic"
  depends_on "python@3.8"

  resource "libarchive-c" do
    url "https://files.pythonhosted.org/packages/63/fe/9e6c78db381934e28c7ec3d30d4f209fe24442d17f1bd8c56d13ae185cf6/libarchive-c-2.9.tar.gz"
    sha256 "9919344cec203f5db6596a29b5bc26b07ba9662925a05e24980b84709232ef60"
  end

  resource "progressbar" do
    url "https://files.pythonhosted.org/packages/a3/a6/b8e451f6cff1c99b4747a2f7235aa904d2d49e8e1464e0b798272aa84358/progressbar-2.5.tar.gz"
    sha256 "5d81cb529da2e223b53962afd6c8ca0f05c6670e40309a7219eacc36af9b6c63"
  end

  resource "python-magic" do
    url "https://files.pythonhosted.org/packages/84/30/80932401906eaf787f2e9bd86dc458f1d2e75b064b4c187341f29516945c/python-magic-0.4.15.tar.gz"
    sha256 "f3765c0f582d2dfc72c15f3b5a82aecfae9498bd29ca840d72f37d7bd38bfcd5"
  end

  def install
    venv = virtualenv_create(libexec, Formula["python@3.8"].opt_bin/"python3")
    venv.pip_install resources
    venv.pip_install buildpath

    bin.install libexec/"bin/diffoscope"
    libarchive = Formula["libarchive"].opt_lib/"libarchive.#{OS.mac? ? "dylib" : "so"}"
    bin.env_script_all_files(libexec/"bin", :LIBARCHIVE => libarchive)
  end

  test do
    (testpath/"test1").write "test"
    cp testpath/"test1", testpath/"test2"
    system "#{bin}/diffoscope", "--progress", "test1", "test2"
  end
end
